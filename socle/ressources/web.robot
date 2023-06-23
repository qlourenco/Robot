# -*- coding: utf-8 -*-
*** Settings ***
Documentation       Ressource de référence pour Appium et Selenium.
...
...                 Cette libraire propose une forme d'héritage vers Appium et Selenium.
...                 Les mots-clés conçus sont en communs avec ceux de ``appium.robot``
...                 et de ``selenium.robot``.
...
...                 Avec ``web.robot``, nous sommes en mesure d'effectuer les tests
...                 aussi bien sur navigateur d'ordinateur que sur un appareil mobile.
...                 Cependant, certains mots-clés n'existent pas dans l'une ou l'autre librairie.
...
...                 Ci-dessous un tableau indiquant les mots-clés fonctionnels dans un seul environnement.
...                 | = Selenium uniquement = | = Appium uniquement = |
...                 | Obtenir Mon Url | Obtenir L'Uri Vers Appium Server |
...                 | Obtenir Mon Titre | Obtenir La Plateforme Du Device |
...                 | Obtenir La Cellule Du Tableau | Ouvrir L'Application Sur Le Device |
...                 | Obtenir Mon Url | Deployer Et Ouvrir L'Application Sur Le Device |
...                 | Choisir Le Fichier | Taper Sur l'Element |
...                 | Choisir Dans La Liste |  |
...                 | Choisir Dans La Liste Unique |  |
...                 | Choisir Le Bouton Radio |  |
...                 | Cocher Un Element |  |
...                 | Changer De Navigateur |  |
...
...                 Pour tous ces mots-clés il est préférable de les appeler directement depuis
...                 leur propre librairie plutôt que depuis ``web.robot`` et indiquer qu'un de
...                 ces mots-clés fait parti du test tant que les deux librairies n'ont pas les
...                 équivalents pour tous. Autrement, le test échouerait car il ne trouverait
...                 pas l'équivalence dans l'autre fichier.

Resource            utils.robot
Resource            log.robot
Resource            selenium.robot


*** Variables ***
# Timeout global
${GLOBAL_TIMEOUT}  30s

# Modify Headers and Header Tool extensions
${WEB_PATH2CHROME}     ${PATH2CHROME}


*** Keywords ***
Temps De Reaction Utilisateur
    [Documentation]   Simuler le temps de réaction d'un utilisateur humain (entre 0,5s et 1s)

    ${radomWait}=    evaluate    random.uniform(0.5,1)    modules=random
    sleep    ${radomWait}


Modifier le timeout global
    [Documentation]  Modification du timeout appliqué à tous les mots clés web
    [Arguments]  ${myTimeout}

    Set Global Variable    ${GLOBAL_TIMEOUT}    ${myTimeout}


# ==============================================================================
# Parametrer navigateur ========================================================
# ==============================================================================
Sur Mon Navigateur
    [Documentation]     Aiguillage en fonction de la variable Jenkins MY_DEVICE.
    ...
    ...                 Navigateur Selenium ou Appium à partir du dictionnaire Jenkins MY_ENVIRONMENT_SETTINGS.
    ...
    ...                 Par défaut le DEVICE est PC.
    ...
    ...                 *Arguments :*
    ...                 - ``myKeyword``       est le mot-clé a appeler dans la librairie aiguillée.
    ...                 - ``myVarargs``       sont les arguments à ajouter lors de l'appel au mot-clé.
    ...                 *Return* : le résultat de la requete du mot cle.
    [Arguments]         ${myKeyword}    @{myVarargs}

    ${theDevice}=    OperatingSystem.Get Environment Variable    MY_DEVICE    default=PC
    ${passed}    ${libraryName}=    Run Keyword And Ignore Error    Get From Dictionary    ${FBO_DEVICES}    ${theDevice}libraryName
    # compatibilite ascendante - Si le dictionnaire n'existe pas,  prendre selenium par defaut
    ${libraryName}=    Set Variable If  '${passed}'=='PASS'             ${libraryName}    selenium
    ${returnValue}=    Run Keyword      ${libraryName}.${myKeyword}     @{myVarargs}

    [Return]    ${returnValue}


Fixer L'Url De Base
    [Documentation]     Positionner l'url de base en fonction de l'environnement.
    ...
    ...                 *Arguments :*
    ...                 - ``myAppEnvSettings``        ?
    [Arguments]         ${myAppEnvSettings}

    ${WEB_BASE_URL}=    ${URL}
    Set Suite Variable    ${WEB_BASE_URL}


# Definir Les Capacites Chrome
#     [Documentation]     Définir le paramétrage de fonctionnement de chrome_options.
#     ...
#     ...                 *Return* : la liste des options définies.
#     [Arguments]    ${localBrowser}=${True}    ${myAuthExtension}=${EMPTY}    ${myDownloadDirectory}=${WORKSPACE}

#     ${options}=    Evaluate      sys.modules['selenium.webdriver'].ChromeOptions()      sys, selenium.webdriver
#     # set path 2 chrome binary if needed
#     ${options.binary_location}=     Set Variable If    ${localBrowser}     ${WEB_PATH2CHROME}    ${EMPTY}
#     ${prefs}=    Create Dictionary
#     # To set default language and localization FR (as xpath contains localized text)
#     ...              intl.accept_languages=fr,fr_FR
#     # To Turns off multiple download warning, https://stackoverflow.com/questions/15817328/disable-chrome-download-multiple-files-confirmation
#     ...              profile.content_settings.exceptions.automatic_downloads."*".setting=1
#     ...              profile.default_content_settings.popups=0
#     ...              profile.cookie_controls_mode=0
#     # To turns off download prompt
#     ...              download.prompt_for_download=${FALSE}
#     ...              download.directory_upgrade=${TRUE}
#     # Set download Directory
#     ...              download.default_directory=${myDownloadDirectory}
#     #https://stackoverflow.com/questions/24507078/how-to-deal-with-certificates-using-selenium
#     ...              acceptSslCerts=${TRUE}
#     ...              acceptInsecureCerts=${TRUE}

#     # Set extension to handle authentication if needed
#     ${exist_extension}=    Run Keyword And Return Status    Should Not Be Empty    ${myAuthExtension}
#     Run keyword If    ${exist_extension}
#     ...              Call Method    ${options}    add_extension    ${myAuthExtension}
#     # disable-extension incompatible avec l'extension auth
#     Call Method     ${options}      add_argument                --disable-dev-shm-usage
#     Call Method     ${options}      add_argument                --disable-gpu
#     Call Method     ${options}      add_argument                --no-sandbox
#     # https://stackoverflow.com/questions/24507078/how-to-deal-with-certificates-using-selenium
#     Call Method     ${options}      add_argument                ignore-certificate-errors
#     Call Method     ${options}      add_argument                allow-running-insecure-content
#     Call Method     ${options}      add_argument                unsafely-treat-insecure-origin-as-secure
#     # to allow unpacked extension loading
#     Call Method     ${options}      add_experimental_option     useAutomationExtension   ${FALSE}
#     Call Method     ${options}      add_experimental_option     prefs   ${prefs}

#     [Return]        ${options}

Definir Les Capacites Chrome
    [Documentation]     Définir le paramétrage de fonctionnement de chrome_options.
    ...
    ...                 *Return* : la liste des options définies.
    [Arguments]    ${localBrowser}=${True}    ${myAuthExtension}=${EMPTY}    ${myDownloadDirectory}=${WORKSPACE}

    ${options}=    Evaluate      sys.modules['selenium.webdriver'].ChromeOptions()      sys, selenium.webdriver
    ${prefs}=    Create Dictionary
    # To set default language and localization FR (as xpath contains localized text)
    ...              intl.accept_languages=fr,fr_FR
    # To Turns off multiple download warning, https://stackoverflow.com/questions/15817328/disable-chrome-download-multiple-files-confirmation
    ...              profile.content_settings.exceptions.automatic_downloads."*".setting=1
    ...              profile.default_content_settings.popups=0
    ...              profile.cookie_controls_mode=0
    # To turns off download prompt
    ...              download.prompt_for_download=${FALSE}
    ...              download.directory_upgrade=${TRUE}
    # Set download Directory
    ...              download.default_directory=${myDownloadDirectory}
    #https://stackoverflow.com/questions/24507078/how-to-deal-with-certificates-using-selenium
    ...              acceptSslCerts=${TRUE}
    ...              acceptInsecureCerts=${TRUE}

    # Set extension to handle authentication if needed
    ${exist_extension}=    Run Keyword And Return Status    Should Not Be Empty    ${myAuthExtension}
    Run keyword If    ${exist_extension}
    ...              Call Method    ${options}    add_extension    ${myAuthExtension}
    # disable-extension incompatible avec l'extension auth
    Call Method     ${options}      add_argument                --disable-dev-shm-usage
    Call Method     ${options}      add_argument                --disable-gpu
    Call Method     ${options}      add_argument                --no-sandbox
    Call Method     ${options}      add_argument                --headless
    Call Method     ${options}      add_argument                window-size\=1920,1080
    # https://stackoverflow.com/questions/24507078/how-to-deal-with-certificates-using-selenium
    Call Method     ${options}      add_argument                ignore-certificate-errors
    Call Method     ${options}      add_argument                allow-running-insecure-content
    Call Method     ${options}      add_argument                unsafely-treat-insecure-origin-as-secure
    # to allow unpacked extension loading
    Call Method     ${options}      add_experimental_option     useAutomationExtension   ${FALSE}
    Call Method     ${options}      add_experimental_option     prefs   ${prefs}

    [Return]        ${options}


Definir Les Capacites Firefox
    [Documentation]     Définir le paramétrage de fonctionnement de ff_options.
    ...
    ...                 *Return* : la liste des options définies.
    [Arguments]    ${localBrowser}=${True}    ${myAuthExtension}=${EMPTY}    ${myDownloadDirectory}=${WORKSPACE}

    #${options}=    Evaluate      sys.modules['selenium.webdriver'].FirefoxOptions()      sys, selenium.webdriver
    # set path 2 firefox binary if needed
    #${options.binary_location}=     Set Variable If    ${localBrowser}     ${WEB_PATH2CHROME}    ${EMPTY}
    
    # Set extension to handle authentication if needed
    # ${ff_profile}=    Evaluate      sys.modules['selenium.webdriver'].FirefoxProfile()      sys, selenium.webdriver
    # ${exist_extension}=    Run Keyword And Return Status    Should Not Be Empty    ${myAuthExtension}
    # Run keyword If    ${exist_extension}
    # ...              Call Method    ${ff_profile}    add_extension    ${myAuthExtension}
     
    # # To set default language and localization FR (as xpath contains localized text)
    # Call Method     ${ff_profile}    set_preference    intl.accept_languages          fr
    # # To turns off download prompt
    # Call Method     ${ff_profile}    set_preference    privacy.window.maxInnerWidth  1920
    # Call Method     ${ff_profile}    set_preference    privacy.window.maxInnerWidth  1080
    # Call Method     ${ff_profile}    set_preference    browser.download.panel.shown   ${FALSE}
    # Call Method     ${ff_profile}    set_preference    browser.download.folderList    2
    # Call Method     ${ff_profile}    set_preference    browser.download.dir           ${myDownloadDirectory}
    # Call Method     ${ff_profile}    set_preference    browser.helperApps.neverAsk.saveToDisk    application/pdf;application/zip;application/vnd.ms-excel;application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;application/octet-stream

    ${ff_profile}=    Evaluate      sys.modules['selenium.webdriver'].FirefoxProfile()      sys, selenium.webdriver

    Call Method    ${ff_profile}    set_preference    intl.accept_languages  fr
    Call Method    ${ff_profile}    set_preference    privacy.window.maxInnerWidth  1920
    Call Method    ${ff_profile}    set_preference    privacy.window.maxInnerHeight  1080
    Call Method    ${ff_profile}    set_preference    browser.download.panel.shown  ${False}
    Call Method    ${ff_profile}    set_preference    browser.download.folderList  2
    Call Method    ${ff_profile}    set_preference    browser.download.dir  ${myDownloadDirectory}
    Call Method    ${ff_profile}    set_preference    browser.download.useDownloadDir  ${True}
    Call Method    ${ff_profile}    set_preference    browser.download.manager.showWhenStarting  ${False}
    Call Method    ${ff_profile}    set_preference    browser.helperApps.neverAsk.saveToDisk    application/pdf;application/zip;application/vnd.ms-excel;application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;application/octet-stream

    [Return]        ${ff_profile}  


# ==============================================================================
# Ouvrir navigateur ============================================================
# ==============================================================================
Ouvrir Chrome Avec Auth Pour Pdf
    [Documentation]     Ouvrir un fichier Pdf avec un navigateur.

    web.Sur Mon Navigateur      Ouvrir Chrome Avec Auth Pour Pdf


Ouvrir Chrome
    [Documentation]     Ouvrir Google Chrome sur le device.

    web.Sur Mon Navigateur      Ouvrir Chrome


Ouvrir ChromeDistant
    [Documentation]     Ouvrir Google Chrome de maniere distante sur le device.

    web.Sur Mon Navigateur      Ouvrir ChromeDistant


Ouvrir Chrome Avec Authentification Proxy
    [Documentation]     Start chrome browser.
    ...                 | Based on https://stackoverflow.com/questions/37456794/chrome-modify-headers-in-selenium-java-i-am-able-to-add-extension-crx-through

    web.Sur Mon Navigateur      Ouvrir Chrome Avec Authentification Proxy


Ouvrir Chrome Avec Profil
    [Documentation]     DEPRECATED - Ouvrir Chrome sur un profil utilisateur.
    ...
    ...                 *Arguments :*
    ...                 - ``myPath2Profile``      le chemin vers le profil a charger.
    [Arguments]    ${myPath2Profile}

    web.Sur Mon Navigateur      Ouvrir Chrome Avec Profil    ${myPath2Profile}


Ouvrir Firefox
    [Documentation]     Ouvrir Firefox sur le device.

    web.Sur Mon Navigateur      Ouvrir Firefox


Ouvrir Firefox Avec BMP
    web.Sur Mon Navigateur      Ouvrir Firefox Avec BMP


Ouvrir Firefox Avec Authentification Proxy
    web.Sur Mon Navigateur      Ouvrir Firefox Avec Authentification Proxy


# ==============================================================================
# Se deplacer ==================================================================
# ==============================================================================
Aller Vers Le Site
    [Documentation]     Charger l'URL.
    ...
    ...                 *Arguments :*
    ...                 - ``myUrl``           est l'URL vers laquelle se diriger.
    ...                 - ``myExpectedText``  est le texte attendu pour confirmer que la bonne page a été atteinte.
    [Arguments]         ${myUri}    ${myExpectedText}

    ${myUrl}=    web.obtenir url a partir uri    ${myUri}
    web.Sur Mon Navigateur      Aller Vers Le Site    ${myUrl}    ${myExpectedText}

Naviguer Avec Le Browser Vers Le Site
    [Documentation]     Ouvrir le navigateur myBrowser ou MY_BROWSER par défaut, se positionner sur l'URL et vérifier la présence du texte sur la page.
    ...
    ...                 *Arguments :*
    ...                 - ``myUrl``           est l'URL vers laquelle se diriger.
    ...                 - ``myExpectedText``  est le texte attendu pour confirmer que la bonne page a été atteinte.
    ...                 - ``myBrowser``       est le navigateur à utiliser.
    [Arguments]         ${myUrl}    ${myExpectedText}    ${myBrowser}=%{MY_BROWSER}

    web.Sur Mon Navigateur      Naviguer Avec Le Browser Vers Le Site    ${myUrl}    ${myExpectedText}    ${myBrowser}


Naviguer Avec Le Browser Vers Le Site En Utilisant L'URL Complete
    [Documentation]     Ouvrir le navigateur myBrowser ou MY_BROWSER par défaut, se positionner sur l'URL et vérifier la présence du texte sur la page.
    ...
    ...                 *Arguments :*
    ...                 - ``myUrl``           est l'URL vers laquelle se diriger.
    ...                 - ``myExpectedText``  est le texte attendu pour confirmer que la bonne page a été atteinte.
    ...                 - ``myBrowser``       est le navigateur à utiliser.
    [Arguments]         ${myUrl}    ${myExpectedText}    ${myBrowser}=%{MY_BROWSER}    ${myAlias}=None

    web.Sur Mon Navigateur      Naviguer Avec Le Browser Vers Le Site En Utilisant L'URL Complete    ${myUrl}    ${myExpectedText}    ${myBrowser}    ${myAlias}

Naviguer Avec Le Browser Local Vers Le Site
    [Documentation]     Ouvrir le navigateur myBrowser ou MY_BROWSER par défaut, se positionner sur l'URL et vérifier la présence du texte sur la page.
    ...
    ...                 *Arguments :*
    ...                 - ``myUrl``           est l'URL vers laquelle se diriger.
    ...                 - ``myExpectedText``  est le texte attendu pour confirmer que la bonne page a été atteinte.
    ...                 - ``myBrowser``       est le navigateur à utiliser.
    [Arguments]         ${myUrl}    ${myExpectedText}    ${myBrowser}=%{MY_BROWSER}

    web.Sur Mon Navigateur      Naviguer Avec Le Browser Local Vers Le Site    ${myUrl}    ${myExpectedText}    ${myBrowser}

Naviguer Vers Le Site
    [Documentation]     Ouvrir le navigateur Chrome avec le profil, se positionner sur l'URL et vérifier la présence du texte sur la page.
    ...
    ...                 *Arguments :*
    ...                 - ``myUrl``           est l'URL vers laquelle se diriger.
    ...                 - ``myProfile``       est le profil à utiliser.
    ...                 - ``myExpectedText``  est le texte attendu pour confirmer que la bonne page a été atteinte.
    [Arguments]         ${myUrl}    ${myProfile}    ${myExpectedText}

    web.Sur Mon Navigateur      Naviguer Vers Le Site    ${myUrl}    ${myProfile}    ${myExpectedText}


Naviguer Vers Le Site Contenant Un Pdf
    [Documentation]     Ouvrir le navigateur Chrome avec le profil, se positionner sur l'URL et vérifier la présence du texte sur la page.
    ...
    ...                 *Arguments :*
    ...                 - ``myUrl``           est l'URL vers laquelle se diriger.
    ...                 - ``myExpectedText``  est le texte attendu pour confirmer que la bonne page a été atteinte.
    ...                 - ``myBrowser``       est le navigateur à utiliser.
    [Arguments]         ${myUrl}    ${myExpectedText}    ${myBrowser}=%{MY_BROWSER}

    web.Sur Mon Navigateur      Naviguer Vers Le Site Contenant Un Pdf    ${myUrl}    ${myExpectedText}    ${myBrowser}


Se Positionner Sur La Fenetre
    [Documentation]     Se positionner sur l'onglet correspondant.
    ...
    ...                 *Arguments :*
    ...                 - ``myTitle``     est l'onglet sur lequel il faut se positionner.
    [Arguments]         ${myTitle}

    web.Sur Mon Navigateur      Se Positionner Sur La Fenetre    ${myTitle}


# ==============================================================================
# Recuperer des donnees ========================================================
# ==============================================================================
Obtenir Mon Url
    [Documentation]     Obtenir l'URL courante.
    ...
    ...                 *Return* : l'adresse de la page actuelle.

    ${currentLocation}=      web.Sur Mon Navigateur      Obtenir Mon Url

    [Return]                ${currentLocation}


Obtenir Mon Titre
    [Documentation]     Obtenir le titre de la page courante.
    ...
    ...                 *Return* : le titre de la page actuelle.

    ${title}=      web.Sur Mon Navigateur      Obtenir Mon Titre

    [Return]    ${title}


Obtenir La Cellule Du Tableau
    [Documentation]     Obtenir le contenu d'une cellule précise.
    ...
    ...                 *Arguments :*
    ...                 - ``myTBodyIdLocator``    est la localisation du tableau.
    ...                 - ``myRow``               est la ligne demandée.
    ...                 - ``myCol``               est la colonne demandée.
    ...                 *Return* : la valeur de la cellule.
    [Arguments]         ${myTBodyIdLocator}    ${myRow}    ${myCol}

    ${cellValue}=      web.Sur Mon Navigateur      Obtenir La Cellule Du Tableau    ${myTBodyIdLocator}    ${myRow}    ${myCol}

    [Return]            ${cellValue}


Obtenir Le Texte De L'Attribut
    [Arguments]     ${myLocator}    ${myAttribute}    ${myTimeout}=${GLOBAL_TIMEOUT}    ${myError}=None

    ${myText}=    web.Sur Mon Navigateur    Obtenir Le Texte De L'Attribut    ${myLocator}    ${myAttribute}    ${myTimeout}    ${myError}

    [Return]    ${myText}


Obtenir Le Texte Complet De L'Element
    [Arguments]    ${myLocator}

    web.Sur Mon Navigateur      Obtenir Le Texte Complet De L'Element    ${myLocator}


obtenir la liste des elements correspondants au locator
    [Arguments]    ${myLocator}

    ${returnItems}=    web.Sur Mon Navigateur      obtenir la liste des elements correspondants au locator    ${myLocator}

    [Return]    ${returnItems}


Obtenir Le Texte De L'Element
    [Arguments]    ${myLocator}    ${myTimeout}=${GLOBAL_TIMEOUT}    ${myError}=None

    ${cellValue}=    web.Sur Mon Navigateur    Obtenir Le Texte De L'Element    ${myLocator}    ${myTimeout}    ${myError}

    [Return]            ${cellValue}


Obtenir L'Element Le Plus Proche De La Liste
    [Documentation]     Obtenir l'élément le plus ressemblant de la liste.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est la localisation de la liste.
    ...                 - ``myExpectedText``  est le choix attendu.
    ...                 - ``myTimeout``       est le temps d'attente maximum pour trouver le choix attendu.
    [Arguments]         ${myLocator}    ${myExpectedOption}    ${myTimeout}=${GLOBAL_TIMEOUT}

    ${cellValue}=    web.Sur Mon Navigateur      Obtenir L'Element Le Plus Proche De La Liste    ${myLocator}    ${myExpectedOption}    ${myTimeout}
    [Return]            ${cellValue}


Obtenir Url A Partir Uri
    [Documentation]     Construction de l'url a partir de l'uri et de l'url de base de l'environnement.
    ...
    ...                 *Arguments :*
    ...                 - ``myUri``       est l'URI a convertir en URL.
    ...                 *Return* : l'URL construite depuis l'URI.
    [Arguments]    ${myUri}

    return from keyword if    "${myUri}"==""    ${WEB_BASE_URL}
    ${url}=    Set Variable    ${WEB_BASE_URL}/${myUri}
    [Return]    ${url}


obtenir le nombre de ligne du tableau
    [Arguments]    ${myTableIdLocator}

    ${count}=    web.sur mon navigateur    obtenir le nombre de ligne du tableau    ${myTableIdLocator}
    [Return]    ${count}


obtenir le nombre de ligne du tableau sans locator
    [Arguments]    ${myTablexpath}

    ${count}=    web.sur mon navigateur    obtenir le nombre de ligne du tableau sans locator    ${myTablexpath}
    [Return]    ${count}

obtenir le nombre d elements correspondants au locator
    [Arguments]    ${myXpath}

    ${count}=    web.sur mon navigateur    obtenir le nombre d elements correspondants au locator    ${myXpath}
    [Return]    ${count}

obtenir la cellule du tableau hors entete
    [Arguments]    ${myTableIdLocator}    ${myRow}    ${myCol}

    ${cellValue}=    web.sur mon navigateur    obtenir la cellule du tableau hors entete    ${myTableIdLocator}    ${myRow}    ${myCol}
    [Return]    ${cellValue}


Le Texte De L'Element Doit Avoir La Valeur Attendue
    [Documentation]    Compare le texte de l'élément avec la valeur attendue
    [Arguments]    ${myLocator}    ${targetValue}

    web.Sur Mon Navigateur    Le Texte De L'Element Doit Avoir La Valeur Attendue    ${myLocator}    ${targetValue}


Le Texte De L'Element Doit Etre Conforme A L'Expression Reguliere
    [Documentation]    Compare le texte de l'élément avec l'expression régulière
    [Arguments]    ${myLocator}     ${myRegexp}

    web.Sur Mon Navigateur    Le Texte De L'Element Doit Etre Conforme A L'Expression Reguliere    ${myLocator}     ${myRegexp}


L'Element Doit Etre Desactive
    [Documentation]    Vérifie que l'élément est désactivé
    [Arguments]    ${myLocator}

    web.Sur Mon Navigateur    L'Element Doit Etre Desactive    ${myLocator}



# ==============================================================================
# vérifier l'etat de la page ===================================================
# ==============================================================================
La Page Doit Etre Prete
    [Documentation]     Vérifier que la page est chargée.

    web.Sur Mon Navigateur      La Page Doit Etre Prete


Confirmer Que La Page Est Prete
    [Documentation]     Attendre que la page soit chargée.

    web.Sur Mon Navigateur      Confirmer Que La Page Est Prete


La Page Ne Contient Pas L'Element
    [Documentation]     Vérifier que la page ne contient pas un élément.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est l'élément qui doit être absent.
    [Arguments]         ${myLocator}    ${myMessage}=None    ${nothingOnFailure}=${FALSE}

    ${previousBehavior}=    Run Keyword If    ${nothingOnFailure}    Register Keyword To Run On Failure    NOTHING
    web.Sur Mon Navigateur      La Page Ne Contient Pas L'Element    ${myLocator}    ${myMessage}
    Run Keyword If    ${nothingOnFailure}    Register Keyword To Run On Failure    ${previousBehavior}



La Page Contient
    [Documentation]     Vérifier que la page contient un texte.
    ...
    ...                 *Arguments :*
    ...                 - ``myExpectedText``      est le texte attendu sur la page.
    ...                 - ``myTimeout``           est le temps d'attente maximum autorise pour trouver le texte.
    [Arguments]         ${myExpectedText}    ${myTimeout}=${GLOBAL_TIMEOUT}    ${myError}=None

    web.Sur Mon Navigateur      La Page Contient    ${myExpectedText}    ${myTimeout}    ${myError}


La Page Contient L'Element
    [Documentation]     Vérifier que la page contient un élément.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est l'élément qui doit être present.
    ...                 - ``myTimeout``       est le temps d'attente maximum pour que l'élément apparaisse.
    [Arguments]         ${myLocator}    ${myTimeout}=${GLOBAL_TIMEOUT}    ${myError}=None    ${nothingOnFailure}=${FALSE}

    ${previousBehavior}=    Run Keyword If    ${nothingOnFailure}    Register Keyword To Run On Failure    NOTHING
    web.Sur Mon Navigateur      La Page Contient L'Element    ${myLocator}    ${myTimeout}    ${myError}
    Run Keyword If    ${nothingOnFailure}    Register Keyword To Run On Failure    ${previousBehavior}


La Page Contient L'Element Visible
    [Documentation]     Vérifier que la page contient un élément visible.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est l'élément qui doit être present.
    ...                 - ``myTimeout``       est le temps d'attente maximum pour que l'élément apparaisse.
    [Arguments]         ${myLocator}    ${myTimeout}=${GLOBAL_TIMEOUT}    ${myError}=None

    web.Sur Mon Navigateur      La Page Contient L'Element Visible    ${myLocator}    ${myTimeout}    ${myError}


Attendre La Disparition Element
    [Documentation]     Attendre qu'un élément disparaisse de la page.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est l'élément qui doit disparaître.
    ...                 - ``myTimeout``       est le temps d'attente maximum pour que l'élément disparaisse.
    [Arguments]         ${myLocator}    ${myTimeout}=180s

    web.Sur Mon Navigateur      Attendre La Disparition Element    ${myLocator}   ${myTimeout}


l'element n'est plus visible sur la page
	[Arguments]    ${myLocator}    ${myTimeout}=${GLOBAL_TIMEOUT}

	web.sur mon navigateur    l'element n'est pas visible sur la page    ${myLocator}    ${myTimeout}


Verifier le titre de la page
    [Documentation]  Verifie que le titre de la page correspond bien a la valeur attendue
    [Arguments]     ${title}    ${myMessage}=None

    web.sur mon navigateur    Verifier le titre de la page     ${title}    ${myMessage}


L'url de la page doit avoir la valeur attendue
    [Documentation]  Compare l'url de la page active avec la valeur attendue
    [Arguments]     ${targetValue}

    web.sur mon navigateur    L'url de la page doit avoir la valeur attendue    ${targetValue}


# ==============================================================================
# Choisir un élément ===========================================================
# ==============================================================================
Choisir Dans La Liste
    [Documentation]     Faire un choix dans une liste déroulante.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est la localisation de la liste.
    ...                 - ``myOption``        est l'élément à sélectionner dans la liste déroulante.
    ...                 - ``myTimeout``       est le temps d'attente maximum pour trouver l'élément.
    [Arguments]         ${myLocator}    ${myOption}    ${myTimeout}=${GLOBAL_TIMEOUT}

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur      Choisir Dans La Liste    ${myLocator}    ${myOption}    ${myTimeout}


Choisir Dans La Liste Par Valeur
    [Documentation]     Faire un choix dans une liste déroulante par attribut value.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est la localisation de la liste.
    ...                 - ``myOption``        est l'élément à sélectionner dans la liste déroulante.
    ...                 - ``myTimeout``       est le temps d'attente maximum pour trouver l'élément.
    [Arguments]         ${myLocator}    ${myOption}    ${myTimeout}=${GLOBAL_TIMEOUT}

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur      Choisir Dans La Liste Par Valeur    ${myLocator}    ${myOption}    ${myTimeout}


Choisir Dans La Liste Unique
    [Documentation]     Faire un choix unique dans une liste déroulante.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est la localisation de la liste.
    [Arguments]         ${myLocator}    # l'élément que l'on veut selectionner dans la liste déroulante est unique

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur      Choisir Dans La Liste Unique    ${myLocator}


Choisir Bouton Radio
    [Documentation]     Sélectionner un bouton radio.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est l'ensemble des boutons radios existants.
    ...                 - ``myChoice``        est le bouton radio à sélectionner.
    [Arguments]         ${myLocator}    ${myChoice}

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur      Choisir Bouton Radio    ${myLocator}      ${myChoice}


Le Bouton Radio Doit Etre Selectionne
    [Documentation]     S'assurer que le bouton radio est sélectionné'.
    ...
    ...                 *Arguments :*
    ...                 - ``myName``     est le nom du groupe de choix possible (name).
    ...                 - ``myValue``      est le bouton radio qui doit être sélectionné.
    ...                 _Version Selenium Only._
    [Arguments]         ${myName}    ${myValue}

    web.Sur Mon Navigateur    Le Bouton Radio Doit Etre Selectionne    ${myName}    ${myValue}


Le Bouton Radio Ne Doit Pas Etre Selectionne
    [Documentation]     S'assurer que le bouton radio n'est pas sélectionné'.
    ...
    ...                 *Arguments :*
    ...                 - ``myName``     est le nom du groupe de choix possible (name).
    ...                 _Version Selenium Only._
    [Arguments]         ${myName}

    web.Sur Mon Navigateur    Le Bouton Radio Ne Doit Pas Etre Selectionne    ${myName}


Cocher Un Element
    [Documentation]     Cocher un élément sur une page.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est la checkbox à cocher.
    [Arguments]         ${myLocator}    ${myTimeout}=${GLOBAL_TIMEOUT}   ${myError}=None

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur    Cocher Un Element    ${myLocator}    ${myTimeout}   ${myError}


# ==============================================================================
# Saisir du texte ==============================================================
# ==============================================================================
Saisir Un Secret Dans Element Actif
    [Documentation]     Saisir du texte non enregistré dans un élément.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est l'élément dans lequel le texte sera saisi.
    ...                 - ``myText``          est le texte à saisir.
    [Arguments]         ${myLocator}    ${myText}    ${myTimeout}=${GLOBAL_TIMEOUT}    ${myError}=None

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur    Saisir Un Secret Dans Element Actif    ${myLocator}    ${myText}    ${myTimeout}    ${myError}


Saisir Dans Element Actif Et Sortir Du Champ
    [Documentation]     Saisir du texte dans un élément puis quitter le champ.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est l'élément dans lequel le texte sera saisi.
    ...                 - ``myText``          est le texte à saisir.
    [Arguments]         ${myLocator}     ${myText}

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur      Saisir Dans Element Actif Et Sortir Du Champ    ${myLocator}  ${myText}


Appuyer Sur Une Touche
    [Documentation]     Appuyer sur une touche du clavier.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est l'élément dans lequel la touche sera appuyée.
    ...                 - ``myAsciiCode``     est le code ASCII de la touche sur laquelle on veut appuyer.
    [Arguments]         ${myLocator}    ${myAsciiCode}

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur      Appuyer Sur Une Touche   ${myLocator}    ${myAsciiCode}


Appuyer Sur des Touches
    [Documentation]     Appuyer sur des Touches du clavier.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est l'élément dans lequel les touches seront appuyée.
    ...                 - ``myAsciiCode``   est le code ASCII des  touches sur laquelles on veut appuyer.
    [Arguments]         ${myLocator}    ${myAsciiCode}

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur      Appuyer Sur des Touches   ${myLocator}    ${myAsciiCode}


Saisir Dans Element Actif
    [Documentation]     Saisir du texte dans un élément.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est l'élément dans lequel le texte sera saisi.
    ...                 - ``myText``          est le texte à saisir.
    [Arguments]         ${myLocator}    ${myText}    ${myTimeout}=${GLOBAL_TIMEOUT}    ${myError}=None

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur    Saisir Dans Element Actif    ${myLocator}    ${myText}    ${myTimeout}    ${myError}


Saisir Dans Element Actif Avec Javascript
    [Documentation]     Saisir du texte dans un élément avec Javascript.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est l'élément dans lequel le texte sera saisi.
    ...                 - ``myText``          est le texte à saisir.
    [Arguments]         ${myLocator}    ${myText}    ${myAttribute}=value    ${myTimeout}=${GLOBAL_TIMEOUT}    ${myError}=None

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur    Saisir Dans Element Actif Avec Javascript    ${myLocator}    ${myText}    ${myAttribute}    ${myTimeout}    ${myError}


Saisir Dans Element Actif Sans Effacer L'Existant
    [Documentation]     Saisir du texte dans un élément à la suite de ce qui est déjà présent.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est l'élément dans lequel le texte sera saisi.
    ...                 - ``myText``          est le texte à saisir.
    [Arguments]         ${myLocator}    ${myText}    ${myTimeout}=${GLOBAL_TIMEOUT}    ${myError}=None

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur    Saisir Dans Element Actif Sans Effacer L'Existant    ${myLocator}    ${myText}    ${myTimeout}    ${myError}
    
Double Cliquer Sur Element Visible Et Actif
    [Documentation]     Double Cliquer sur un élément visible et actif sur la page.
    ...
    ...                 *Arguments :*
    ...                 - ``myXpathLocator``      est l'élément sur lequel on veut cliquer.
    ...                 - ``myTimeout``           est le temps d'attente maximum pour trouver l'élément.
    [Arguments]         ${myXpathLocator}    ${myTimeout}=${GLOBAL_TIMEOUT}   ${myError}=None

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur      Double Cliquer Sur Element Visible Et Actif    ${myXpathLocator}    ${myTimeout}    ${myError}

Saisir Avec Webdriver
    [Documentation]     Saisir du texte dans un élément directement depuis le webdriver.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est l'élément dans lequel le texte sera saisi.
    ...                 - ``myText``          est le texte à saisir.
    [Arguments]         ${myLocator}    ${myText}

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur      Saisir Avec Webdriver    ${myLocator}    ${myText}


Saisir Un Secret Avec Webdriver
    [Documentation]     Saisir du texte non enregistré dans un élément directement depuis le webdriver.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est l'élément dans lequel le texte sera saisi.
    ...                 - ``myText``          est le texte à saisir.
    [Arguments]         ${myLocator}    ${myText}

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur    Saisir Un Secret Avec Webdriver       ${myLocator}    ${myText}


Saisir Avec Javascript
    [Documentation]     Saisir du texte dans un élément en utilisant un script.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est l'élément dans lequel le texte sera saisi.
    ...                 - ``myText``          est le texte à saisir.
    [Arguments]         ${myLocator}    ${myText}    ${myAttribute}=value

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur    Saisir Avec Javascript    ${myLocator}    ${myText}    ${myAttribute}


Saisir Avec Script
    [Documentation]     Saisir du texte dans un élément en utilisant un script.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est l'élément dans lequel le texte sera saisi.
    ...                 - ``myText``          est le texte à saisir.
    [Arguments]         ${myLocator}    ${myText}

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur    Saisir Avec Script        ${myLocator}    ${myText}


Effacer Dans Element Actif
    [Documentation]     Effacer du texte dans un élément.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est l'élément dans lequel le texte effacé.
    [Arguments]         ${myLocator}    ${myTimeout}=${GLOBAL_TIMEOUT}    ${myError}=None

    web.Sur Mon Navigateur    Effacer Dans Element Actif    ${myLocator}    ${myTimeout}    ${myError}


# ==============================================================================
# Cliquer ======================================================================
# ==============================================================================
Cliquer Sur Element Visible
    [Documentation]     Cliquer sur un élément visible sur la page.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``         est l'élément sur lequel cliquer.
    ...                 - ``myTimeout``         est le temps d'attente maximum pour trouver l'élément.
    [Arguments]         ${myLocator}     ${myTimeout}=${GLOBAL_TIMEOUT}

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur      Cliquer Sur Element Visible     ${myLocator}     ${myTimeout}


Cliquer Sur Element Actif
    [Documentation]     Cliquer sur un élément actif sur la page.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est l'élément sur lequel cliquer.
    ...                 - ``myTimeout``       est le temps d'attente maximum pour trouver l'élément.
    [Arguments]         ${myLocator}    ${myTimeout}=${GLOBAL_TIMEOUT}

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur      Cliquer Sur Element Actif    ${myLocator}     ${myTimeout}


Cliquer Sur Element Visible Et Actif
    [Documentation]     Cliquer sur un élément visible et actif sur la page.
    ...
    ...                 *Arguments :*
    ...                 - ``myXpathLocator``      est l'élément sur lequel on veut cliquer.
    ...                 - ``myTimeout``           est le temps d'attente maximum pour trouver l'élément.
    [Arguments]         ${myXpathLocator}    ${myTimeout}=${GLOBAL_TIMEOUT}   ${myError}=None

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur      Cliquer Sur Element Visible Et Actif    ${myXpathLocator}    ${myTimeout}    ${myError}


Double Cliquer Sur Element Visible Et Actif Avec Javascript
    [Documentation]     Double Cliquer sur un élément visible et actif sur la page avec Javascript.
    ...
    ...                 *Arguments :*
    ...                 - ``myXpathLocator``      est l'élément sur lequel on veut cliquer.
    ...                 - ``myTimeout``           est le temps d'attente maximum pour trouver l'élément.
    [Arguments]         ${myXpathLocator}    ${myTimeout}=${GLOBAL_TIMEOUT}   ${myError}=None

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur      Double Cliquer Sur Element Visible Et Actif Avec Javascript    ${myXpathLocator}    ${myTimeout}    ${myError}


Cliquer Sur Element Visible Et Actif Avec Javascript
    [Documentation]     Cliquer sur un élément visible et actif sur la page avec Javascript.
    ...
    ...                 *Arguments :*
    ...                 - ``myXpathLocator``      est l'élément sur lequel on veut cliquer.
    ...                 - ``myTimeout``           est le temps d'attente maximum pour trouver l'élément.
    [Arguments]         ${myXpathLocator}    ${myTimeout}=${GLOBAL_TIMEOUT}   ${myError}=None

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur      Cliquer Sur Element Visible Et Actif Avec Javascript    ${myXpathLocator}    ${myTimeout}    ${myError}


Cliquer Sur Element visible et actif apres la disparition d'un autre element qui le cache
    [Documentation]    Clique sur l'element apres la disparition d'un autre qui le cache
    [Arguments]    ${myLocatorClick}    ${myLocatorElementQuiCache}    ${myTimeout}=${GLOBAL_TIMEOUT}

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur      Cliquer Sur Element visible et actif apres la disparition d'un autre element qui le cache    ${myLocatorClick}    ${myLocatorElementQuiCache}    ${myTimeout}


Cliquer Sur Element visible et actif le plus a gauche possible
    [Documentation]    Clique sur la zone la plus a gauche possible de l'element
    [Arguments]    ${myLocator}    ${myTimeout}=${GLOBAL_TIMEOUT}

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur      Cliquer Sur Element visible et actif le plus a gauche possible    ${myLocator}    ${myTimeout}


Cliquer Sur Element visible et actif en maintenant des touches
    [Documentation]  Clique sur l'element en maintenant une ou plusieurs touches du clavier
    [Arguments]    ${myLocator}    ${myKeys}   ${myTimeout}=${GLOBAL_TIMEOUT}

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur      Cliquer Sur Element visible et actif en maintenant des touches    ${myLocator}    ${myKeys}   ${myTimeout}


Cliquer Sur Element Avec Webdriver
    [Documentation]     Cliquer sur un élément avec le webdriver sans vérification préalable.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est l'élément sur lequel on veut cliquer.
    [Arguments]         ${myLocator}

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur      Cliquer Sur Element Avec Webdriver      ${myLocator}


Cliquer Sur Element Avec Javascript
    [Documentation]     Cliquer sur un élément en utilisant javascript.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est l'élément sur lequel on veut cliquer.
    [Arguments]         ${myLocator}

    web.Temps De Reaction Utilisateur
    web.Sur Mon Navigateur      Cliquer Sur Element Avec Javascript      ${myLocator}


Accepter La Popup
    [Documentation]    Accepte la Pop-up qui apparaît à l'écran et retourne le message qu'elle affiche
    [Arguments]    ${myTimeout}=${GLOBAL_TIMEOUT}

    ${myMessage}=    web.Sur Mon Navigateur    Accepter La Popup    ${myTimeout}

    [Return]    ${myMessage}


Verifier Le Message De La Popup Et L'Accepter
    [Documentation]    Vérifie le message de la Pop-up qui apparaît à l'écran et l'accepter
    ...
    ...                 *Arguments :*
    ...                 - ``myMessage``     est le message que l'on veut vérifier.
    ...                 - ``myTimeout``     est le temps d'attente maximum pour trouver l'élément.
    [Arguments]         ${myMessage}    ${myTimeout}=${GLOBAL_TIMEOUT}

    web.Sur Mon Navigateur    Verifier Le Message De La Popup Et L'Accepter    ${myMessage}    ${myTimeout}


# ==============================================================================
# Generalites ==================================================================
# ==============================================================================
Capturer L'Ecran
    [Documentation]     Faire une capture d'écran de la page actuelle.

    web.Sur Mon Navigateur      Capturer L'Ecran


Capture L'Ecran Avec Timestamp Pour Nom De Fichier
    [Documentation]   Réalise une capture d'écran avec un timestamp pour nom de fichier
    web.Sur Mon Navigateur      Capture L'Ecran Avec Timestamp Pour Nom De Fichier


Capture L'Ecran Avec Timestamp Pour Page Identifier De Fichier
    [Documentation]   Réalise une capture d'écran avec un timestamp pour nom de fichier
    web.Sur Mon Navigateur      Capture L'Ecran Avec Timestamp Pour Page Identifier De Fichier


Fixer Le Zoom
    [Documentation]     Effectuer un zoom sur la page.
    ...
    ...                 *Arguments :*
    ...                 - ``myZoom``      est la puissance du zoom à effectuer.
    [Arguments]         ${myZoom}

    web.Sur Mon Navigateur      Fixer Le Zoom    document.body.style.zoom=${myZoom}


Fermer Tous Les Navigateurs
    [Documentation]     Fermer tous les navigateurs ouverts.

    web.Sur Mon Navigateur      Fermer Tous Les Navigateurs


Actualiser la page
    [Documentation]  Actualise la page active du navigateur

    web.Sur Mon Navigateur      Actualiser la page


Fermer l'onglet du navigateur
    [Documentation]  Ferme l'onglet actif du navigateur

    web.Sur Mon Navigateur      Fermer l'onglet du navigateur


Changer De Navigateur
    [Documentation]     Changer de navigateur.
    ...
    ...                 *Arguments :*
    ...                 - ``myIndex``       est le nouveau navigateur à ouvrir.
    [Arguments]         ${myIndex}

    web.Sur Mon Navigateur      Changer De Navigateur    ${myIndex}


Positionner le curseur sur un element
    [Documentation]  Place le curseur de la souris au dessus d'un element
    [Arguments]  ${myLocator}

    web.sur mon navigateur  Positionner le curseur sur un element    ${myLocator}


Selectionner La Frame
    [Documentation]  Selectionne la frame ou l'iframe
    [Arguments]  ${myLocator}

    web.sur mon navigateur  Selectionner La Frame    ${myLocator}


Deselectionner La Frame
    [Documentation]  Deselectionne la frame ou l'iframe

    web.sur mon navigateur  Deselectionner La Frame


# ==============================================================================
# Telechargement ===============================================================
# ==============================================================================
Le Telechargement Doit Etre En Cours
    [Documentation]     Attendre le démarrage du téléchargement.

    Sleep    1s


Le Dernier Fichier Telecharge Doit Etre Complet
    [Documentation]     Vérifier que le fichier a été completement téléchargé.
    ...
    ...                 *Return* : le chemin vers le fichier téléchargé.

    ${path2DownloadedFile}=    utils.Obtenir Le Chemin Vers Le Dernier Fichier Du Repertoire    ${WORKSPACE}
    Should Not End With    ${path2DownloadedFile}    .part
    Should Not End With    ${path2DownloadedFile}    .tmp
    Should Not End With    ${path2DownloadedFile}    .crdownload

    [Return]    ${path2DownloadedFile}


Obtenir Le Dernier Fichier Telecharge
    [Documentation]     Obtenir le dernier fichier téléchargé.
    ...
    ...                 *Arguments :*
    ...                 - ``myRetryInterval``     est le temps d'attente entre deux tentatives de récuperation du fichier.
    ...                 *Return* : le chemin vers le fichier téléchargé.
    [Arguments]         ${myRetryInterval}=5s

    web.Le Telechargement Doit Etre En Cours
    ${path2DownloadedFile}=    Wait Until Keyword Succeeds    20x     ${myRetryInterval}    le dernier fichier telecharge doit etre complet

    [Return]    ${path2DownloadedFile}


Se Positionner Sur L'Element
    [Documentation]    Scroll de la page jusqu'à l'element
    [Arguments]    ${my_locator}

    selenium.Se Positionner Sur L'Element    ${my_locator}
