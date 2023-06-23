#!/usr/bin/env python
#-*- coding: utf-8 -*-

#from tkinter import S
from asyncore import read
import pandas as pd
import numpy as np
import sys
import csv
import os
import time
import pyini
import configparser
from dask import dataframe as dd
from robot.api import logger
from s3Library import s3Library


class pandaLibrary():

    # L'instance est cree pour une suite de test ainsi la dataframe est accessible pour tous les tests case ce qui permet de lire le fichier Excel une seule fois
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        self._dfCurrent = pd.DataFrame()
        self.dask_df = None
        self._dfBaseLine = None
        self._dfExcel = pd.DataFrame()
        self._workbook = None
        self.s3 = s3Library()
        self.config = configparser.ConfigParser()

    # ==========================================================================
    # KEYWORDS =================================================================
    # ==========================================================================

    def get_current_row_count(self, mydf):
        ''' Get row count from current dataframe.
        '''

        return len(mydf.index)

    def get_row_count_to_XL(self, myPath2file, mySheetName):
        
        pandaLibrary.read_from_XL(self, myPath2file=myPath2file, mySheetName=mySheetName)

        row_count= pandaLibrary.get_current_row_count(self, self._dfExcel)
        
        return row_count

    # grab data from html
    def read_from_html(self, my_path2_html_file, my_table_id, my_load_mode='create'):
        ''' Load html file table into a dataframe.

        :param my_path2_html_file:   path to html file to load
        :param my_table_id:   table id to load from html
        :param my_load_mode:   create to load in a new dataframe, append to load in current dataframe
        '''

        message = f"Reading table {my_table_id} from {my_path2_html_file} with mode {my_load_mode} ..."
        self._debug(message)
        attrs = {}
        attrs["id"] = my_table_id

        if my_load_mode == 'create':
            df = pd.read_html(
                io=my_path2_html_file,
                attrs=attrs
            )
            self._dfCurrent = df[0]
            message= u"Current dataframe refreshed"
            self._debug(message)
        else:
            message= u"Current dataframe shape {0}\n{1}".format(self._dfCurrent.shape, self._dfCurrent.head(2))
            self._debug(message)

            df = pd.read_html(
                io=my_path2_html_file,
                attrs=attrs
            )

            message= u"New dataframe shape {0}\n{1}".format(df[0].shape, df[0].head(2))
            self._debug(message)

            self._dfCurrent = pd.concat(
                objs=[self._dfCurrent, df[0]],
                verify_integrity=True,
                ignore_index=True
            )

            message= u"Current dataframe appended"
            self._debug(message)
        
        message= u"Current dataframe shape {0}\n{1}".format(self._dfCurrent.shape, self._dfCurrent.head(2))
        self._debug(message)

        return len(self._dfCurrent.index)

    # Gerer le fichier Excel ===================================================
    def read_and_filter_from_S3_huge_CSV(self, my_cols_to_retrieve, my_filter_values, my_target_directory, my_sep=';', my_blocksize='10MB'):
        ''' Charger et filtrer un gros fichier CSV dans la dataframe.

        :param my_cols_to_retrieve: liste des noms de colonne a lire
        :param my_filter_values: liste nom de colonne==valeur 
        :param my_sep: CSV separator character
        '''
        my_bucket='cdh-pfdatanoprodjddtapas-492187'

        s3_creds = self.s3.Create_Sts_Session_Refresh_With_Role()
        storage_options = {'key': s3_creds.access_key, 'secret': s3_creds.secret_key,'token': s3_creds.token}

        filenames, nb_file = self.s3.List_Files_On_Bucket(my_bucket, my_prefix='jddcontratoffredetails/raw')

        my_path2_file, my_filenames= self.s3.Compare_date_last_modified(filenames, nb_file, my_bucket)

        my_path_local_file= self.s3.Download_File(my_bucket,my_filenames, my_target_directory)

        message= f"read {my_path2_file} from s3"
        self._debug(message)

        # Pour forcer si besoin le nom du fichier PFDATA à utiliser
        #my_path2_file= 's3://'+my_bucket +'/'+'jddcontratoffredetails/raw/PFDATA_JDD_Recette_Contrat_Offre_Details_20220714.csv'

        self.dask_df = dd.read_csv(
            # my_path2_file,
            my_path_local_file,
            storage_options=storage_options,
            sep=my_sep,
            encoding='utf-8',
            na_filter=False,
            dtype=str,
            engine='python',
            usecols=my_cols_to_retrieve,
            blocksize=my_blocksize,
            on_bad_lines='skip'
        )

        message= f"dask dataframe loaded with {self.dask_df.npartitions} partitions"
        self._debug(message)
        # application du filtre PDC NULL
        self.dask_df = self.dask_df[self.dask_df['pdc'] != 'NULL']

        # application des différents filtres
        for column, target_values in my_filter_values.items():
            self.dask_df = self.dask_df[self.dask_df[column] == target_values]

        return  self.dask_df, self.dask_df.npartitions

    def read_rows_from_dask_df_partition(self, my_dask_df, my_partition):
        
        # récupération des lignes présente dans la dask data frame selon la partition
        self._dfBaseLine = my_dask_df.partitions[my_partition].compute()

        # suppression des doublons sur le pdc
        self._dfBaseLine = self._dfBaseLine.drop_duplicates(subset='pdc', keep='last', inplace=False)
        
        self._dfCurrent = self._dfBaseLine
        
        # obtenir le nombre de ligne présente dans la dataframe current
        row_df_count= pandaLibrary.get_current_row_count(self, self._dfCurrent)
        message= f"{row_df_count} ligne(s) présente dans la partition {my_partition}"
        logger.info(message)

        # Récupération des index présent dans la dataframe current
        rows_df_indices = self._dfCurrent.index

        return    rows_df_indices, row_df_count

    def read_from_CSV(self, my_path2_file, my_sep=';', my_skip_rows=0):
        ''' Charger un fichier CSV avec son chemin dans la dataframe.

        :param my_path2_file: path to CSV file to load in current dataframe
        :param my_sep: CSV separator character
        :param my_skip_rows: index of row to begin the load (0 mean first line)

        '''

        message = f"Loading data from csv file {my_path2_file} with sep='{my_sep}' in the dataframe ..."
        self._debug(message)

        #https://www.dataquest.io/blog/excel-and-pandas/
        #https://stackoverflow.com/questions/32591466/python-pandas-how-to-specify-data-types-when-reading-an-excel-file
        self._dfBaseLine = pd.read_csv(
            my_path2_file,
            sep=my_sep,
            skiprows=my_skip_rows, 
            encoding='utf-8', 
            na_filter=False, 
            dtype=str, 
            engine='python'
        )
        self._dfCurrent = self._dfBaseLine

        message= u"dataframe loaded with a shape {0}\n{1}".format(self._dfBaseLine.shape, self._dfBaseLine.head(2))
        self._debug(message)


    def read_from_XL(self, myPath2file, mySheetName, mySkipRows=0):
        ''' Charger un fichier Excel avec son chemin dans la dataframe.

        :param path2file:   le chemin du classeur
        :type path2file:    string
        '''

        #https://www.dataquest.io/blog/excel-and-pandas/
        #https://stackoverflow.com/questions/32591466/python-pandas-how-to-specify-data-types-when-reading-an-excel-file
        self._dfBaseLine = pd.read_excel(
            io=myPath2file,
            sheet_name=mySheetName,
            skiprows=mySkipRows,
            na_filter=False,
            dtype=str,
            engine='openpyxl'
        )
        
        self._dfExcel = self._dfBaseLine

        message= u"dataframe loaded with a shape {0}\n{1}".format(self._dfBaseLine.shape, self._dfBaseLine.head(2))
        self._debug(message)


    def write_to_XL(self, myDF, myPath2file, mySheetName='Sheet1', myStartRow=0, myStartCol=0, myMode='w'):
        ''' Ecrire la dataframe dans un fichier Excel.
        '''

        self.dftmp= pd.DataFrame(myDF)
        with pd.ExcelWriter(
            path=myPath2file,
            mode=myMode,
            engine='openpyxl'
        ) as writer:
            self.dftmp.to_excel(
                excel_writer=writer,
                index=False,
                header=True,
                sheet_name=mySheetName,
                startrow=myStartRow,
                startcol=myStartCol,
            )

        message= u"Excel créé avec les colonnes et la 1ère donnée"
        self._debug(message)

    def append_to_XL(self, myDF, myPath2file, mySheetName='Sheet1', myStartRow=2, myStartCol=0, myMode='a'):
        ''' Ecrire la dataframe dans un fichier Excel.
        '''

        self.dftmp= pd.DataFrame(myDF)
        with pd.ExcelWriter(
            path=myPath2file,
            mode=myMode,
            engine='openpyxl',
            if_sheet_exists='overlay',
        ) as writer:
            self.dftmp.to_excel(
                excel_writer=writer,
                index=False,
                header=False,
                sheet_name=mySheetName,
                startrow=myStartRow,
                startcol=myStartCol,
            )

        message= u"Excel créé avec les colonnes et la 1ère donnée"
        self._debug(message)

    def write_to_csv(self, myPath2file, myDF, myEncoding):
        
        self.dftmp= pd.DataFrame(myDF)

        self.dftmp.to_csv(
            myPath2file,
            sep=';',
            encoding=myEncoding,
            mode='w',
            index=False,
            header=True,
        )

        message= u"csv créé avec les colonnes et la 1ère donnée"
        self._debug(message)

    def append_to_csv(self,myPath2file, myDF, myEncoding):

        self.dftmp= pd.DataFrame(myDF)

        self.dftmp.to_csv(
            myPath2file,
            sep=';',
            encoding=myEncoding,
            mode='a',
            index=False,
            header=False,
        )

        message= u"csv renseigné avec les données"
        self._debug(message)

    def filter_dataframe_equal(self, myColumnName, myValue):
        ''' filtrer la dataframe.

        :param myColumnName:   la colonne qui porte le filtre
        :param myValue:    la valeur du filtre
        '''

        message = u"Filtering dataframe with query {0}=={1} ...".format(myColumnName, myValue)
        self._debug(message)

        #https://stackoverflow.com/questions/11869910/pandas-filter-rows-of-dataframe-with-operator-chaining
        self._dfCurrent = self._dfCurrent[self._dfCurrent[myColumnName]==myValue]
        returnListIndices = self._dfCurrent.index

        message= u"dataframe filtered with a shape {0}\n{1}".format(self._dfCurrent.shape,self._dfCurrent.head(2))
        self._debug(message)

        return    returnListIndices


    def filter_dataframe_isin(self, my_col_name, my_list_values):
        ''' filter current dataframe on one column with multiple values.

        :param my_col_name:   Column name
        :param my_list_values:   Values as a list

        '''

        message = f"Filtering dataframe with query {my_col_name}={my_list_values} is in ..."
        self._debug(message)

        #https://stackoverflow.com/questions/35164019/filter-multiple-values-using-pandas
        self._dfCurrent = self._dfCurrent[self._dfCurrent[my_col_name].isin(my_list_values)]
        returnListIndices = self._dfCurrent.index

        message= u"dataframe filtered with a shape {0}\n{1}".format(self._dfCurrent.shape,self._dfCurrent.head(2))
        self._debug(message)

        return    returnListIndices

    def filter_dataframe_isnull(self, myColumnName):
        ''' filtrer la dataframe.

        :param myColumnName:   la colonne qui porte le filtre

        '''

        message = u"Filtering dataframe with query {0} is null ...".format(myColumnName)
        self._debug(message)

        #https://stackoverflow.com/questions/11869910/pandas-filter-rows-of-dataframe-with-operator-chaining
        self._dfCurrent = self._dfCurrent[self._dfCurrent[myColumnName].isnull()]
        returnListIndices = self._dfCurrent.index

        message= u"dataframe filtered with a shape {0}\n{1}".format(self._dfCurrent.shape,self._dfCurrent.head(2))
        self._debug(message)

        return    returnListIndices


    def get_row_as_dictionary(self, my_indice, my_dataframe='CURRENT'):
        ''' get a row from dataframe as a dictionary.

        :param my_indice:   l'indice de la ligne

        '''

        message = f"get single row {my_indice} from {my_dataframe} dataframe..."
        self._debug(message)

        index=int(my_indice)
        if my_dataframe=='CURRENT':
            # https://pandas.pydata.org/pandas-docs/stable/user_guide/indexing.html
            return_dict = self._dfCurrent.loc[[index],:].to_dict('records')
        else:
            return_dict = self._dfBaseLine.loc[[index],:].to_dict('records')

        return    return_dict


    def read_from_records(self, myRecordsList):
        ''' Charger une liste d'enregistrements (dictionnaire) dans la dataframe .

        :param myRecordsList:   la liste des enregistrements (qui sont des dictionnaires)
        :type myRecordsList:    list
        '''

        message = u"Loading data from records list {0} in the dataframe ...".format(myRecordsList)
        self._debug(message)

        #https://stackoverflow.com/questions/20638006/convert-list-of-dictionaries-to-a-pandas-dataframe
        self._dfBaseLine = pd.DataFrame.from_records(myRecordsList) 
        self._dfCurrent = self._dfBaseLine

        message= u"dataframe loaded with a shape {0}\n{1}".format(self._dfBaseLine.shape, self._dfBaseLine.head(2))
        self._debug(message)


    def select_slice_columns(self, my_slice):
        ''' Selectionner une partie des colonnes.

        :param my_slice:   la partie des colonnes sous la forme 1:3 
        :type my_slice:    string
        '''

        message = "select columns slice {} in the dataframe ...".format(my_slice)
        self._debug(message)

        slice_list = my_slice.split(':')
        start_col_index = slice_list[0]
        end_col_index = slice_list[1]

        message = "start_col_index={},  end_col_index={},  slice_list={}".format(start_col_index,end_col_index,slice_list)
        self._debug(message)

        self._dfCurrent = self._dfCurrent.loc[:, start_col_index:end_col_index]

    def read_file_dat(self, my_path_file_dat):

        print(f'file={my_path_file_dat}')

        file= self.config.read(my_path_file_dat)
        print(f'text={file}')
        section= self.config.sections()
        print(f'section={section}')
        my_dict = {}
        for section in self.config.sections():
            my_dict[section] = {}
            for key, val in self.config.items(section):
                my_dict[section][key] = val

        return my_dict

    # ==========================================================================
    # PRIVATE ==================================================================
    # ==========================================================================
    def _debug(self, message):
        logger.debug(message)
