# -*- coding: utf-8 -*-
*** Settings ***
Documentation       Ressource utilisée pour diverses tâches de type utilitaire.
...
...                 Cette librairie a de nombreuses fonctionnalités pour manipuler
...                 des fichiers. Elle peut :
...                 - Créer, déplacer et supprimer des fichiers.
...                 - Comparer des éléments pour déterminer lequel est le plus ressemblant.
...                 - Convertir des valeurs en euros.
...                 - Obtenir des chemins vers des fichiers ou des dossiers.
...                 - Obtenir différentes dates (premier jour du mois, dernier jour, et autres).
...                 - Récupérer la date actuelle et la comparer avec une date donnée.

Library             DateTime
Library             String
Library             Collections
Library             OperatingSystem
Library             collections.UserString    seq

Resource            log.robot


*** Keywords ***
Combine Dictionary
    [Arguments]    ${targetDic}    ${joinedDic}

    ${keys}=    Get Dictionary Keys    ${joinedDic}
	FOR    ${aKey}    IN    @{keys}
	    Set To Dictionary    ${targetDic}    ${aKey}=${joinedDic.${aKey}}
	END


convertir format France en date
    [Documentation]    Conversion d'une date d/m/Y en timestamp ISO8601
    [Arguments]    ${myDateFrance}    ${myformat}=timestamp

    # si date None, retourne EMPTY
    ${success}  ${length}=    Run keyword And Ignore Error    Get Length    ${myDateFrance}
    ${estVide}=    Set Variable If    '${success}'=='FAIL'  ${TRUE}   ${FALSE}
    
    # On tente une conversion avec le format France
    ${success}    ${timestamp}=    Run Keyword And Ignore Error    Convert Date    ${myDateFrance}    date_format=%d/%m/%Y
    # En cas d'echec on verifie que c'est deja un format ISO8601
    ${timestamp}=    Run Keyword If    ${estVide}    Set Variable    ${EMPTY}
    ...                     ELSE IF    '${success}' == 'FAIL'    Convert Date    ${myDateFrance}
    ...                        ELSE                              Set Variable    ${timestamp}

    [return]    ${timestamp}

    
Compter Le Nombre De Lignes Du fichier
    [Documentation]    Compter le nombre de ligne du fichier
    ...
    ...                 *Arguments :*
    ...                 - ``myPath2file``        est le chemin vers le fichier.
    [Arguments]    ${myPath2file}


    ${payLoad}=    OperatingSystem.Get File    ${myPath2file}

    # Compter le nombre de lignes du fichier
    ${returnNbLines}=    String.Get Line Count    ${payLoad}

    [Return]    ${returnNbLines}


La Suite Robot Doit Contenir Des Taches
        [Documentation]    Vérifier la présence de tâches dans la suite Robot
        ...
        ...                 *Arguments :*
        ...                 - ``myPath2file``        est le chemin vers le fichier suite robot.
        [Arguments]    ${myPath2file}

        OperatingSystem.File Should Not Be Empty    ${myPath2file}
        ${suiteRobot}=    OperatingSystem.Get File    ${myPath2file}

        # Compter le nombre de lignes du fichier
        ${nbLines}=    utils.Compter Le Nombre De Lignes Du fichier    ${myPath2file}
        ${lastLineIndex}=    Evaluate    ${nbLines} - 1

        # Extraire la dernière ligne
        ${lastLine}=    String.Get Line    ${suiteRobot}    ${lastLineIndex}

        # Si c'est la ligne des tâches, alors aucune tâche de présente
        Should Not Contain    ${lastLine}    Tasks


instancier le template avec les variables
    [Documentation]    Replace les variables a l'interieur du fichier template
    [Arguments]    ${myPath2Template}

    ${template}=    OperatingSystem.Get File    ${myPath2Template}
    ${instance}=     Replace Variables    ${template}

    [Return]    ${instance}


Obtenir L'Element Le Plus Proche
    [Documentation]     Retourner la chaîne la plus proche.
    ...
    ...                 *Arguments :*
    ...                 - ``myExpectedString``        est la chaîne de caractères recherchee.
    ...                 - ``myListStrings``           est une liste de chaînes de caractères à parcourir pour retrouver celle cherchée.
    ...                 *Return* : la chaîne de caractère la plus proche de celle cherchée.
    [Arguments]         ${myExpectedString}    ${myListStrings}

    ${maxProximityRatio}=           Set Variable    0
    ${maxProximityString}=          Set Variable    ${myExpectedString}

    FOR    ${triedString}    IN    @{myListStrings}
        ${proximityRatio}=         Evaluate    difflib.SequenceMatcher(None, "${triedString}", "${myExpectedString}").ratio()    modules=difflib
        ${maxProximityString}=     Set Variable If    ${proximityRatio} > ${maxProximityRatio}    ${triedString}    ${maxProximityString}
        ${maxProximityRatio}=      Set Variable If    ${proximityRatio} > ${maxProximityRatio}    ${proximityRatio}   ${maxProximityRatio}
    END

    [Return]    ${maxProximityString}


Obtenir Le Chemin Vers Le Dernier Fichier Du Repertoire
    [Documentation]     Identifier le dernier fichier en date de création du répertoire.
    ...
    ...                 *Arguments :*
    ...                 - ``myFolder``      est le répertoire dans lequel aller.
    ...                 *Return* : le chemin vers le dernier fichier crée dans le répertoire.
    [Arguments]         ${myFolder}

    # https://stackoverflow.com/questions/2953834/windows-path-in-python
    ${myFolderPath}=    String.Replace String    ${myFolder}    \\    /
    #https://stackoverflow.com/questions/23435084/how-to-read-access-a-filename-with-non-ascii-characters?rq=1
    ${fileName}=        Evaluate            max(['${myFolderPath}/' + f for f in os.listdir('${myFolderPath}')], key=os.path.getctime)    os
    # https://stackoverflow.com/questions/21129020/how-to-fix-unicodedecodeerror-ascii-codec-cant-decode-byte
    ${utf8Path2File}=   Convert To String   ${fileName}

    [Return]    ${utf8Path2File}


Creer Le Fichier
    [Documentation]     Créer le fichier et ecraser s'il existe.
    ...
    ...                 *Arguments :*
    ...                 - ``myFileContent``     est le contenu du fichier à créer.
    ...                 - ``myPath2File``       est le chemin du futur fichier.
    ...                 - ``myCode``            est le type d'encodage à utiliser.
    [Arguments]         ${myFileContent}    ${myPath2File}    ${myCode}=UTF-8

    OperatingSystem.Create File    ${myPath2File}    ${myFileContent}    encoding=${myCode}

Creer Le Dossier
    [Documentation]     Créer le fichier et ecraser s'il existe.
    ...
    ...                 *Arguments :*
    ...                 - ``myPath``       est le chemin du futur dossier.
    [Arguments]         ${myPath}

    OperatingSystem.Create Directory    ${myPath}

Deplacer Le Fichier Vers
    [Documentation]     Déplacer le fichier s'il existe.
    ...
    ...                 *Arguments :*
    ...                 - ``mySourceFile``      est l'emplacement initial du fichier.
    ...                 - ``myTargetFile``      est l'emplacement final du fichier.
    [Arguments]         ${mySourceFile}    ${myTargetFile}

    ${isPresent}=       Run Keyword And Return Status    OperatingSystem.File Should Exist      ${mySourceFile}
    Run Keyword If      ${isPresent}    OperatingSystem.Move File    ${mySourceFile}            ${myTargetFile}
    Run Keyword If      ${isPresent}    OperatingSystem.File Should Not Be Empty                ${myTargetFile}


Supprimer Le Fichier
    [Documentation]     Supprimer le fichier s'il existe.
    ...
    ...                 *Arguments :*
    ...                 - ``mySourceFile``      est l'emplacement théorique du fichier à supprimer.
    [Arguments]         ${mySourceFile}

    ${isPresent}=       Run Keyword And Return Status    OperatingSystem.File Should Exist    ${mySourceFile}
    Run Keyword If      ${isPresent}    OperatingSystem.Remove File    ${mySourceFile}


Copier Le Fichier Vers
    [Documentation]     Copier le fichier.
    ...
    ...                 *Arguments :*
    ...                 - ``mySourceFile``      est l'emplacement du fichier à copier.
    ...                 - ``myTargetFile``      est l'emplacement où copier le fichier.
    [Arguments]         ${mySourceFile}    ${myTargetFile}

    OperatingSystem.Copy File    ${mySourceFile}    ${myTargetFile}
    OperatingSystem.File Should Not Be Empty        ${myTargetFile}


Remplacer Les Accents
    [Documentation]     Remplacer les caractères accentués, module python unidecode.
    ...
    ...                 *Arguments :*
    ...                 - ``myStringWithAccents``   la chaîne de caractères a encoder.
    [Arguments]         ${myStringWithAccents}

    # prefix r pour Raw string Cf. https://stackoverflow.com/questions/1347791/unicode-error-unicodeescape-codec-cant-decode-bytes-cannot-open-text-file
    ${stripAccents}=    Evaluate    unidecode.unidecode(r"""${myStringWithAccents}""")    unidecode

    [return]            ${stripAccents}


La Date Doit Etre Plus Recente
    [Documentation]     Compare la date avec la date du jour - le délai.
    ...
    ...                 *Arguments :*
    ...                 - ``myDate``        est la date à comparer avec la date actuelle.
    ...                 - ``myDelay``       est le délai acceptable entre la date et la date actuelle.
    [Arguments]         ${myDate}    ${myDelay}

    ${dateRef}=         utils.Convertir En Date    ${myDate}
    ${today}=           Get Current Date
    ${triggerTime}=     Convert Time    ${myDelay}
    ${delay}=           Subtract Date From Date    ${today}    ${dateRef}
    Should Be True      ${delay} < ${triggerTime}    Depassement la date ${myDate} depasse le delai ${myDelay}


Convertir En Date
    [Documentation]     Conversion d'un datetime ISO8601 en date france.
    ...
    ...                 *Arguments :*
    ...                 - ``myIso8601``     ?
    ...                 - ``myFormat``      est le format de la date.
    ...                 *Return* : la date actuelle.
    [Arguments]         ${myIso8601}        ${myFormat}=datetime

    ${date}=        Get Substring       ${myIso8601}    0    10
    ${dateTime}=    Run Keyword If  '${date}'==''    Set Variable  ${EMPTY}
    ...                       ELSE    Convert Date  ${date}    result_format=${myFormat}

    [return]        ${dateTime}


Executer
    [Documentation]     Interprêter dynamiquement des mots-clés et arguments générés par concatenation ou autre.
    ...
    ...                 *Arguments :*
    ...                 - ``myKeyword``    	est le mot-clé à interprêter.
    ...                 - ``myArgs``        sont les arguments à ajouter pour le mot-clé à interprêter.
    [Arguments]         ${myKeyword}    @{myArgs}

    Run Keyword    ${myKeyword}    @{myArgs}


Obtenir Date Du Jour
    [Documentation]     Obtenir la date du jour.
    ...
    ...                 *Return* : La date du jour sous le format jour/mois/année/heure/minute
    [Arguments]    ${result_format}=%d%m%Y%H%M

    ${dateOfTheDay}=    Get Current Date    result_format=${result_format}

    [Return]          ${dateOfTheDay}


Obtenir La Date De La Semaine Precedent La Date Du Jour
    [Documentation]     Obtenir la date de la semaine précédent la date actuelle.
    ...
    ...                 *Return* : la date de la semaine précédente.

    # python:https://code.i-harness.com/fr/q/a7c6
    ${lastWeekDate}=    Evaluate    (datetime.datetime.now() + dateutil.relativedelta.relativedelta(weeks=-1)).strftime('%d%m%Y')    modules=datetime, dateutil, dateutil.relativedelta

    [Return]                     ${lastWeekDate}


Obtenir La Date Du Premier Jour Du Mois Suivant La Date Du Jour
    [Documentation]     Obtenir la date du premier jour du mois suivant.
    ...
    ...                 *Return* : la date du premier jour du mois suivant.

    # python:https://code.i-harness.com/fr/q/a7c6
    ${firstDayOfNextMonth}=    Evaluate    datetime.datetime(datetime.datetime.now().year, (datetime.datetime.now() + dateutil.relativedelta.relativedelta(months=1)).month, 1)    modules=datetime, dateutil, dateutil.relativedelta

    [Return]                    ${firstDayOfNextMonth}


Obtenir La Date Du Premier Jour Du Mois precedent La Date Du Jour
    [Documentation]     Obtenir la date du premier jour du mois suivant.
    ...
    ...                 *Return* : la date du premier jour du mois suivant.

    # python:https://code.i-harness.com/fr/q/a7c6
    ${firstDayOfPreviousMonth}=    Evaluate    (datetime.datetime.now() + dateutil.relativedelta.relativedelta(months=-1)).strftime('%d/%m/%Y')    modules=datetime, dateutil, dateutil.relativedelta

    [Return]                    ${firstDayOfPreviousMonth}


Obtenir La Date Du Premier Jour Du Mois En Cours
    [Documentation]     Obtenir la date du premier jour du mois en cours.
    ...
    ...                 *Arguments :*
    ...                 - ``myFormat``        est le type de format de sortie demandé.
    ...                 *Return* : le premier jour du mois.
    [Arguments]         ${myFormat}=%d%m%Y

    # python:https://code.i-harness.com/fr/q/a7c6
    ${firstDayOfMonth}=   Evaluate    datetime.datetime(datetime.datetime.now().year, datetime.datetime.now().month, 1).strftime('${myFormat}')    modules=datetime, dateutil, dateutil.relativedelta

    [Return]            ${firstDayOfMonth}


Obtenir La Date Du Dernier Jour Du Mois En Cours
    [Documentation]     Obtenir la date du dernier jour du mois.
    ...
    ...                 *Arguments :*
    ...                 - ``myFormat``        est le type de format de sortie demandé.
    ...                 *Return* : le dernier jour du mois.
    [Arguments]         ${myFormat}=%d%m%Y

    # https://stackoverflow.com/questions/42950/get-last-day-of-the-month-in-python
    ${lastDayOfTheMonth}=       Evaluate    (datetime.datetime(datetime.datetime.now().year, datetime.datetime.now().month, 1) + dateutil.relativedelta.relativedelta(months=1, days=-1)).strftime('${myFormat}')  modules=datetime, dateutil, dateutil.relativedelta

    [Return]            ${lastDayOfTheMonth}


Convertir Euro En Nombre
    [Documentation]     Convertir une valeur d'euros en nombre.
    ...
    ...                 *Arguments :*
    ...                 - ``myCurrencyValue``   est la valeur à convertir.
    ...                 *Return* : la valeur convertie en nombre.
    [Arguments]         ${myCurrencyValue}

    ${isString}=    Run Keyword And Return Status    Should Be String           ${myCurrencyValue}
    ${toNumber}=    Run Keyword If    ${isString}    String.Remove String       ${myCurrencyValue}    €
    ${toNumber}=    Run Keyword If    ${isString}    String.Replace String      ${toNumber}    ${SPACE}    ${EMPTY}
    ${toNumber}=    Run Keyword If    ${isString}    String.Replace String      ${toNumber}    ,    .
    ${toNumber}=    Run Keyword If    ${isString}    Convert To Number          ${toNumber}
    ...    ELSE    Set Variable    ${myCurrencyValue}

    [Return]            ${toNumber}


Renseigner Une Variable
    [Documentation]     Renseigner une variable.
    ...
    ...                 *Arguments :*
    ...                 - ``myVarName``             est le nom de la variable.
    ...                 - ``myVarValue``            est la valeur de la variable.
    ...                 - ``isNotSkippingTrace``    s'il faut garder une trace d'exécution.
    [Arguments]         ${myVarName}    ${myVarValue}    ${isNotSkippingTrace}=True

    Set Variable        ${myVarName}         ${myVarValue}
    Run Keyword If      ${isNotSkippingTrace}   log.Debug    variable [${myVarName}] definie a [${myVarValue}]


Renseigner Une Variable De Suite
    [Documentation]     Renseigner une variable de suite.
    ...
    ...                 *Arguments :*
    ...                 - ``myVarName``             est le nom de la variable.
    ...                 - ``myVarValue``            est la valeur de la variable.
    ...                 - ``isNotSkippingTrace``    s'il faut garder une trace d'exécution.
    [Arguments]         ${myVarName}    ${myVarValue}    ${isNotSkippingTrace}=False

    Set Suite Variable  ${myVarName}         ${myVarValue}
    Run Keyword If      ${isNotSkippingTrace}   log.Debug    variable de suite [${myVarName}] definie a [${myVarValue}]


Renseigner Une Variable De Test
    [Documentation]     Renseigner une variable de test.
    ...
    ...                 *Arguments :*
    ...                 - ``myVarName``             est le nom de la variable.
    ...                 - ``myVarValue``            est la valeur de la variable.
    ...                 - ``isNotSkippingTrace``    s'il faut garder une trace d'exécution.
    [Arguments]         ${myVarName}    ${myVarValue}    ${isNotSkippingTrace}=True

    Set Test Variable   ${myVarName}     ${myVarValue}
    Run Keyword If      ${isNotSkippingTrace}    log.Debug    variable de test [${myVarName}] definie a [${myVarValue}]


Renseigner Le Dictionnaire Avec Une Liste De Paires
    [Documentation]     Renseigner un dictionnaire avec une liste de clé-valeur.
    ...
    ...                 *Arguments :*
    ...                 - ``myTargetedDictionnary``     est le dictionnaire à renseigner.
    ...                 - ``myKeyEqualValueList``       est une liste de clé-valeur.
    [Arguments]         ${myTargetedDictionnary}    @{myKeyEqualValueList}


    FOR    ${keyValue}    IN    @{myKeyEqualValueList}
        utils.Executer    Set To Dictionary    ${myTargetedDictionnary}    ${keyValue}
    END

    log.Info    targetDictionnary: ${myTargetedDictionnary}


Deprecated
    [Documentation]     Décrire un cas déprécié.
    ...
    ...                 *Arguments :*
    ...                 - ``myMsg``       est la description du cas rencontré.
    [Arguments]         ${myMsg}

    Should Not Be Empty    ${myMsg}    Deprecated doit contenir afficher un message
    Should Be Empty        ${myMsg}    Deprecated: ${myMsg}


Obtenir Le Premier Mot
    [Documentation]     Obtenir le premier mot d'une phrase.
    ...
    ...                 *Arguments :*
    ...                 - ``theString``       est la chaîne de chaînes de caractères.
    ...                 *Return* : le premier mot.
    [Arguments]         ${myString}

    ${wordList}=        String.Split String     ${myString}
    ${firstWord}=       Get From List           ${wordList}     0
    [Return]            ${firstWord}


Obtenir Le Dernier Mot
    [Documentation]     Obtenir le dernier mot d'une phrase.
    [Arguments]  ${theString}
    ${wordList}=    String.Split String    ${theString}
    Collections.Reverse List    ${wordList}
    ${lastWord}=    Get From List    ${wordList}    0
    [Return]    ${lastWord}


Controler un montant positif
    [Arguments]  ${montantExtrait}
    ${temp}=    Split String    ${montantExtrait}    :
    ${length}=    Get Length    ${temp}
	${tempSplit}=    Run Keyword And Return If    ${length} >= 2    Split String    ${temp}[1]    €
	${tempSplit}=    Run Keyword And Return If    ${length} == 1    Split String    ${temp}[0]    €
	${tempSplit}=    Set Variable    ${tempSplit}[0]
	${tempSplit}=    Set Variable    ${tempSplit.replace("\n", "").replace(",","")}
	${montantFloat}=    Convert To Number    ${tempSplit}
	${montantAbs}=    Evaluate    abs(${montantFloat})
	Run keyword If    ${montantFloat} != ${montantAbs}		FAIL    Le montant ${montantFloat} n'est pas positif


Obtenir une date inferieure a un nombre de jours donne par rapport a la date du jour
    [Documentation]     Genere une date inferieure de ${nbJours} de la date du jour
    [Arguments]    ${nbJours}

    ${aujourdhui}=  Get Current Date
    ${dateInf}=     Subtract Time From Date   ${aujourdhui}    ${nbJours} days  result_format=%d/%m/%Y
    [Return]    ${dateInf}


La date doit etre plus ancienne
    [Documentation]  La date a comparer doit etre plus ancienne a la date de date de reference
    [Arguments]  ${dateAComparer}  ${dateDeReference}  ${dateFormat}

    ${dateAComparer}=  Convert Date  ${dateAComparer}  date_format=${dateFormat}  result_format=epoch
    ${dateDeReference}=  Convert Date  ${dateDeReference}  date_format=${dateFormat}  result_format=epoch
    ${bool}=  Evaluate  ${dateAComparer} < ${dateDeReference}
    [Return]  ${bool}


La date doit etre plus recente ou egale
    [Documentation]  La date a comparer doit etre plus recente ou egale a la date de dateDeReference
    [Arguments]  ${dateAComparer}  ${dateDeReference}  ${dateFormat}

    ${dateAComparer}=  Convert Date  ${dateAComparer}  date_format=${dateFormat}  result_format=epoch
    ${dateDeReference}=  Convert Date  ${dateDeReference}  date_format=${dateFormat}  result_format=epoch
    ${bool}=  Evaluate  ${dateAComparer} >= ${dateDeReference}
    [Return]  ${bool}


Modifier la valeur d'une cle dans un dictionnaire
    [Documentation]     Modifie la valeur associee a une cle d'un dictionnaire
    [Arguments]     ${dictionnaire}     ${cle}   ${valeur}

    Set To Dictionary   ${dictionnaire}     ${cle}=${valeur}


Ajouter un element dans la liste
    [Arguments]     ${list}     ${element}

    Append To List  ${list}     ${element}


Mettre la chaine de caracteres en majuscules
    [Arguments]  ${chaine}

    ${chaine}=  Convert To Uppercase  ${chaine}
    [Return]  ${chaine}


Mettre la chaine de caracteres en minuscules
    [Arguments]  ${chaine}

    ${chaine}=  Convert To Lowercase  ${chaine}
    [Return]  ${chaine}


Mettre le premier caractere d'une chaine de caracteres en majuscule
    [Arguments]  ${chaine}

    ${premiereLettre}=  Get Substring  ${chaine}  0  1
    ${premiereLettre}=  Convert To Uppercase  ${premiereLettre}
    ${chaine}=  Get Substring  ${chaine}  1
    ${chaine}=  Convert To Lowercase  ${chaine}
    ${chaine}=  Catenate  SEPARATOR=  ${premiereLettre}  ${chaine}
    [Return]  ${chaine}


Executer Un Script Powershell
	[Arguments]  ${cheminAccesScript}
	Run Process    powershell    ${cheminAccesScript}


Executer Un Script Git-bash
    [Documentation]    Appelle git-bash et execute le script
	[Arguments]  ${myWindowsPath2BashScript}

    ${myBashPath2Script}=    utils.Convertir Le Chemin Absolu Windows En Chemin Git-bash    ${myWindowsPath2BashScript}
	Run Process    %{ROBOT_APP}${/}Git${/}git-bash.exe -c ${myBashPath2Script}    shell=True    cwd=%{WORKSPACE}


Convertir Le Chemin Absolu Windows En Chemin Git-bash
    [Documentation]    remplace les \ en / et c: en /c/
	[Arguments]  ${myWindowsPath}

    ${path}=              String.Replace String    ${myWindowsPath}    \\    \/
    ${returnBashPath}=    String.Replace String    ${path}    :    \/
    ${returnBashPath}=    Set Variable    \/${returnBashPath}

    [Return]    ${returnBashPath}


Comparer Le Texte Du Pdf
    [Documentation]     Comparer le texte présents dans le PDF avec le texte attendu.
    ...
    ...                 *Arguments :*
    ...                 - ``myPath2Pdf``        est le chemin vers le PDF à consulter.
    ...                 *Return* : le texte du Pdf.
    [Arguments]       ${txtPDF}   ${txtAttendu}

   ${resultat}=  find  ${txtPDF}   ${txtAttendu}

    [Return]  ${resultat}
