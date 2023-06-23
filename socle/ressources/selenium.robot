# -*- coding: utf-8 -*-
*** Settings ***
Documentation       Ressource wrapper de la SeleniumLibrary.
...
...                 Cette librairie reprend les fonctionnalités présentes dans la librairie
...                 d'origine et propose des mots-clés en français.
...                 = Cas d'utilisation =
...                 Cette librairie est utilisée pour automatiser des tests sur des
...                 navigateurs web depuis un ordinateur. Pour automatiser des tests
...                 sur des appareils mobiles comme des tablettes, des smartphones ou
...                 autre, veuillez vous référer à la librairie
...                 [http://serhatbolsu.github.io/robotframework-appiumlibrary/AppiumLibrary.html|AppiumLibrary]
...                 , voir ``appium.robot`` pour la version française du socle.
...
...                 Pour utiliser ``selenium.robot``, un WebDriver doit se situer dans les variables
...                 de chemins (_path_) ou doit être déjà démarré sur l'ordinateur l'utilisant.
...                 = Localiser des éléments =
...                 Pour localiser un élément avec Selenium, il existe un type d'argument appelé ``locator``.
...                 La plupart du temps, un ``locator`` est donné sous forme de chaîne de caractères suivant
...                 une syntaxe précise, décrite ci-dessous.
...
...                 La librairie peut localiser de diverses manières un élément, que ce soit par ID de l'élément,
...                 les expressions par Xpath, ou bien les sélecteurs CSS. La choix de la stratégie de reconnaissance
...                 de l'élément depuis le sélecteur donné est effectué automatiquement.
...                 = Temps d'attente =
...                 Tous les éléments qui nécessitent d'attendre pour s'assurer qu'ils sont bien
...                 présents disposent d'un temps d'attente de 5 secondes pour la plupart.
...                 Ce temps reste accessible à tout changement, dans le cas où un site
...                 répondrait plus lentement que la moyenne, il serait alors possible de
...                 redéfinir la valeur du temps d'attente. Pour donner un temps d'attente,
...                 il faut écrire "5s" pour donner 5 secondes et non pas seulement 5.
...                 Exemple :
...                 |   selenium.aller vers le site \ \ \ ``http://www.google.com`` \ \ \ Google \ \ \ 30s
...                 Dans cet exemple, une requête est effectuée pour accéder au site "Google.com".
...                 Lors de l'arrivée sur le site, on s'attend à trouver "Google" d'écrit, ce qui
...                 confirmerait que le bon site a été atteint. Enfin, le troisième argument indique
...                 que l'utilisateur accepte d'attendre jusqu'à 30 secondes avant de considérer que le
...                 site est inaccessible. Par défaut, à la place de 30 secondes, le temps d'attente
...                 est basé à 10 secondes, pour ce cas précis.
...                 = Usages =
...                 Dans cette librairie, plusieurs façons d'effectuer des mêmes actions ont
...                 été conçues. Par exemple, pour cliquer il existe les méthodes suivantes :
...                 | = Nom = | = Fonctionnalité = |
...                 | cliquer sur un element visible et actif | Clique en utilisant l'API Selenium. |
...                 | cliquer avec webdriver | Clique sur un élément depuis le WebDriver. |
...                 | cliquer avec javascript | Exécute un script permettant de cliquer sur la page. |
...                 Il en est de même avec les différents types de saisies possibles. Une saisie peut être
...                 soit tracée, soit invisible (dans le cas de mots de passe), il est aussi possible
...                 de saisir du texte avec l'API, avec le WebDriver et avec JavaScript.

Library             OperatingSystem
Library             SeleniumLibrary
Library             RequestsLibrary
Resource            log.robot
Resource            utils.robot
Resource            web.robot


*** Variables ***
&{DOWNLOAD_MANAGER}
...    firefoxDistant=about:downloads
...    chromeDistant=chrome://downloads

&{CHROME_DOWNLOAD_MANAGER}
...    67.0=1
...    83.0=1
...    87.0=2
...    88.0=2


#${WEB_PATH2BMP}          %{ROBOT_HOME}${/}app${/}Portable-Python-Robot-2711.300.1.3${/}App${/}Lib${/}site-packages${/}browsermobproxy
${WEB_PATH2WEBDRIVER}    ${CURDIR}${/}..${/}resources${/}WebDriver
#${WEB_PATH2CHROME}       C:/Users/Public/Documents/robot/app/tnr_socle_automatisation/utils/GoogleChromePortable/Chrome/Application/chrome.exe

# Modify Headers and Header Tool extensions
&{WEB_PROXY_AUTH}
                          # Authentification proxi
...                       name=Authorization    value=Basic
                          # extension chrome
...                       crx=modheader.crx     modHeaderId=idgpnmonknjnojddfkpgkljpfnnfcklj
                          # extension firefox
...                       xpi=header_tool-0.6.2-fx.xpi
...                       path2profile=


*** Keywords ***
Log On Failure
    [Documentation]    Capture et log le fichier html source en cas d'erreur

    SeleniumLibrary.Capture Page Screenshot
    SeleniumLibrary.Log Source  loglevel=DEBUG


Initialiser Selenium
    [Documentation]     Préparer l'initialisation de Selenium.

    # Set Path to selenium Webdriver needed by open browser
    OperatingSystem.Set Environment Variable    PATH    %{PATH};${WEB_PATH2WEBDRIVER}
    # set wait to 10s
    SeleniumLibrary.Set Selenium Implicit Wait    10


# ==============================================================================
# Ouvrir navigateur ============================================================
# ==============================================================================
# TODO REFACTO
Ouvrir Chrome Avec Auth Pour Pdf
    [Documentation]     Ouvrir un fichier Pdf avec un navigateur.
    ...
    ...                 _Version Selenium._

    SeleniumLibrary.Set Selenium Implicit Wait    10
    # enable FlashPlayer
    ${prefs}    Create Dictionary    profile.default_content_setting_values.plugins=1    profile.content_settings.plugin_whitelist.adobe-flash-player=1    profile.content_settings.exceptions.plugins.*,*.per_resource.adobe-flash-player=1    download.default_directory=%{WORKSPACE}
    # launch webdriver with modHeader extension
    ${options}=    Evaluate      sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_extension    ${CURDIR}${/}..${/}resources${/}extensions${/}${WEB_PROXY_AUTH.crx}
    Call Method    ${options}    add_experimental_option    prefs    ${prefs}
    OperatingSystem.Set Environment Variable        PATH    %{PATH};${CURDIR}${/}..${/}resources${/}webdriver
    SeleniumLibrary.Create WebDriver    Chrome      chrome_options=${options}
    # setup headers
    SeleniumLibrary.Go To    chrome-extension://${WEB_PROXY_AUTH.modHeaderId}/icon.png
    SeleniumLibrary.Execute Javascript    localStorage.setItem('profiles', JSON.stringify([{title: 'Selenium', hideComment: true, appendMode: '',headers: [{enabled: true, name: '${WEB_PROXY_AUTH.name}', value: '${WEB_PROXY_AUTH.value}', comment: ''}],respHeaders: [],filters: []}]));
# TODO REFACTO


# Ouvrir Chrome
#     [Documentation]     Ouvrir Google Chrome sur le device.
#     ...
#     ...                 _Version Selenium._
#     [Arguments]    ${myAlias}=None

#     selenium.Initialiser Selenium
#     # si une extension est presente dans TEMPDIR, l'ajouter dans chrome
#     ${path2temp}=    Evaluate    tempfile.gettempdir()    modules=tempfile
#     #${path2ChromeExtension}=    Set Variable    ${path2temp}/crx-auth.zip
#     ${path2ChromeExtension}=    Set Variable    ${EMPTY}
#     ${extensionPresente}=    Run Keyword And Return Status    OperatingSystem.File Should Not Be Empty    ${path2ChromeExtension}
#     ${path2ChromeExtension}=    Set Variable If    ${extensionPresente}    ${path2ChromeExtension}    ${EMPTY}

#     ${chrome_options}=                      web.Definir Les Capacites Chrome
#     #${chrome_options.binary_location}=      Set Variable        ${WEB_PATH2CHROME}
#     ${chrome_capabilities}=                 Call Method         ${chrome_options}    to_capabilities
#     SeleniumLibrary.Create WebDriver        Chrome    alias=${myAlias}    desired_capabilities=${chrome_capabilities}
#     SeleniumLibrary.Maximize Browser Window

Ouvrir Chrome
    [Documentation]     Ouvrir Google Chrome sur le device.
    ...
    ...                 _Version Selenium._
    [Arguments]    ${myAlias}=None
    
    ${chrome_options}=    web.Definir Les Capacites Chrome
    ${chrome_capabilities}=    Call Method    ${chrome_options}    to_capabilities

    Open Browser    browser=chrome


obtenir le gestionnaire de telechargement du navigateur
    ${browser}=    String.Fetch From Left  %{MY_BROWSER}  marker=:
    ${download_manager_url}=    Get From Dictionary  ${DOWNLOAD_MANAGER}  ${browser}

    [Return]    ${download_manager_url}


aller vers le gestionnaire de telechargement
    
    ${download_manager_url}=    obtenir le gestionnaire de telechargement du navigateur
    SeleniumLibrary.Execute Javascript    window.open()
    SeleniumLibrary.Switch Window         locator=NEW
    SeleniumLibrary.Go To                 ${download_manager_url}


le fichier est telecharge completement
    [Arguments]    ${myFileName}

    ${browser}=    String.Fetch From Left  %{MY_BROWSER}  marker=:
    ${file_name}=    Run Keyword
    ...    le fichier est telecharge completement depuis ${browser}    ${myFileName}


le fichier est telecharge completement depuis firefoxDistant
    [Arguments]    ${myFileName}

    # wait 1s
    sleep    1s
    # check progress information is present
    ${max}=    SeleniumLibrary.Execute Javascript      return document.querySelector('#contentAreaDownloadsView .downloadMainArea .downloadContainer .downloadTarget[value="${myFileName}"]').parentNode.getElementsByTagName('progress')[0].getAttribute('max');
    Should Be True  '${max}'=='100'   msg=Pas encore de fichier telecharge
    # get progress value
    ${progress}=    SeleniumLibrary.Execute Javascript      return document.querySelector('#contentAreaDownloadsView .downloadMainArea .downloadContainer .downloadTarget[value="${myFileName}"]').parentNode.getElementsByTagName('progress')[0].getAttribute('value');
    # if progress is None or 100 then file is complete
    Run Keyword If    ${progress} is not None
    ...    Should Be True  '${progress}'=='100'   msg=Pas encore de fichier telecharge
    

le fichier est telecharge completement depuis chromeDistant
    [Arguments]    ${myFileName}

    ${version}=    String.Fetch From Right  %{MY_BROWSER}  marker=:
    ${download_manager_version}=    Get From Dictionary  ${CHROME_DOWNLOAD_MANAGER}    ${version}
    ${file_name}=    Run Keyword
    ...    le fichier est telecharge completement depuis chrome download manager ${download_manager_version}    ${myFileName}


le fichier est telecharge completement depuis chrome download manager 1
    [Arguments]    ${myFileName}

    # https://stackoverflow.com/questions/60426856/could-not-get-downloaded-items-in-chrome-80
    ${fileNameList}=    SeleniumLibrary.Execute Javascript  return document.querySelector('downloads-manager').shadowRoot.querySelector('#downloads-list').items.filter(e => e.state === 'COMPLETE' && e.file_name === '${myFileName}').map(e => e.file_name);
    Should Not Be Empty  ${fileNameList}  msg=Le fichier${myFileName} n'est pas completement telecharge


le fichier est telecharge completement depuis chrome download manager 2
    [Arguments]    ${myFileName}

    # https://stackoverflow.com/questions/60426856/could-not-get-downloaded-items-in-chrome-80
    ${fileNameList}=    SeleniumLibrary.Execute Javascript  return document.querySelector('downloads-manager').shadowRoot.querySelector('#downloadsList').items.filter(e => e.state === 'COMPLETE' && e.fileName === '${myFileName}').map(e => e.fileName);
    Should Not Be Empty  ${fileNameList}  msg=Le fichier${myFileName} n'est pas completement telecharge


obtenir le nom du dernier fichier telecharger 
    [Documentation]    Retourne le nom du dernier fichier telecharger

    ${browser}=    String.Fetch From Left  %{MY_BROWSER}  marker=:
    ${file_name}=    Run Keyword
    ...    obtenir le nom du dernier fichier telecharger depuis ${browser}

    [Return]    ${file_name}


obtenir le nom du dernier fichier telecharger depuis firefoxDistant
    [Documentation]    Retourne le nom du dernier fichier telecharger 

    #https://stackoverflow.com/questions/56543995/how-to-get-the-url-or-filename-being-downloaded-now
    ${fileNameList}=    SeleniumLibrary.Execute Javascript      return document.querySelector('#contentAreaDownloadsView .downloadMainArea .downloadContainer description:nth-of-type(1)').value;
    Should Not Be Empty    ${fileNameList}  msg=Pas encore de fichier telecharge

    [Return]    ${fileNameList}


obtenir le nom du dernier fichier telecharger depuis chromeDistant
    [Documentation]    Retourne le nom du dernier fichier telecharger dans chrome

    ${version}=    String.Fetch From Right  %{MY_BROWSER}  marker=:
    ${download_manager_version}=    Get From Dictionary  ${CHROME_DOWNLOAD_MANAGER}    ${version}
    ${file_name}=    Run Keyword
    ...    obtenir le nom du dernier fichier telecharger depuis chrome download manager ${download_manager_version}

    [Return]    ${file_name}


obtenir le nom du dernier fichier telecharger depuis chrome download manager 1
    [Documentation]    Retourne le nom du dernier fichier telecharger dans chrome

    #Old Style (chrome version < 83)
    ${fileNameList}=    SeleniumLibrary.Execute Javascript      return document.querySelector('downloads-manager').shadowRoot.querySelector('#downloads-list').items.map(e => e.file_name);
    Should Not Be Empty    ${fileNameList}  msg=Pas encore de fichier telecharge

    [Return]    ${fileNameList}[0]


obtenir le nom du dernier fichier telecharger depuis chrome download manager 2
    [Documentation]    Retourne le nom du dernier fichier telecharger dans chrome

    # https://stackoverflow.com/questions/56543995/how-to-get-the-url-or-filename-being-downloaded-now
    ${last_file_name}=    SeleniumLibrary.Execute Javascript     return document.querySelector('downloads-manager').shadowRoot.querySelector('#downloadsList downloads-item').shadowRoot.querySelector('div#content \ #file-link').text;
    Should Not Be Empty    ${last_file_name}  msg=Pas encore de fichier telecharge

    [Return]    ${last_file_name}


obtenir le fichier telecharger depuis selenoid
    [Documentation]    Utilise l'API Selenoid pour obtenir le fichier telecharge par le container selenium

    # ouvrir le gestionnaire de telechargement si necessaire: chrome://downloads ou about:downloads pour firefox
    ${currentUrl}=    SeleniumLibrary.get Location
    ${download_manager_url}=    obtenir le gestionnaire de telechargement du navigateur
    ${originWindowTitle}=    Run keyword Unless    '${currentUrl}'=='${download_manager_url}'    SeleniumLibrary.Get Title
    Run keyword Unless    '${currentUrl}'=='${download_manager_url}'    selenium.aller vers le gestionnaire de telechargement

    # get last download file
    ${downloadedFileName}=    Wait Until Keyword Succeeds    3x    1s    Selenium.obtenir le nom du dernier fichier telecharger
    Wait Until Keyword Succeeds    30x    1s    le fichier est telecharge completement    ${downloadedFileName}

    # https://aerokube.com/selenoid/latest/#_accessing_files_downloaded_with_browser
    ${sessionId}=    SeleniumLibrary.Get Session Id
    RequestsLibrary.Create Session    selenoid    http://137.74.24.198:10444
    ${resp}=    RequestsLibrary.GET On Session       selenoid    /download/${sessionId}/${downloadedFileName}
    Status Should Be  200            ${resp}

    # save file content in Jenkins Workspace
    ${returnPath2File}=    Set Variable    %{WORKSPACE}/${sessionId}_${downloadedFileName}
    OperatingSystem.Create Binary File    ${returnPath2File}    content=${resp.content}

    # delet file after download 
    RequestsLibrary.DELETE On Session       selenoid    /download/${sessionId}/${downloadedFileName}
    Run keyword if   '${download_manager_url}'!= 'chrome://downloads'          SeleniumLibrary.Execute Javascript      document.querySelector('#contentAreaDownloadsView .downloadMainArea .downloadContainer description:nth-of-type(1)').click();
    Run keyword if   '${download_manager_url}'!= 'chrome://downloads'           SeleniumLibrary.Press Keys  None  DELETE
    
    # close download manager and switch to window
    SeleniumLibrary.Close Window
    SeleniumLibrary.Switch Window     locator=title:${originWindowTitle}

    [Return]    ${returnPath2File}


Ouvrir FirefoxDistant
    [Documentation]     Ouvrir Google Chrome de manière distante sur le device (aerokube selenoid).
    ...
    ...                 _Version Selenium._
    [Arguments]    ${myAlias}=None

    selenium.Initialiser Selenium
    # si une extension est presente dans TEMPDIR, l'ajouter dans Firefox
    ${path2temp}=    Evaluate    tempfile.gettempdir()    modules=tempfile
    ${path2FfExtension}=    Set Variable    ${path2temp}/xpi-auth.zip
    ${extensionPresente}=    Run Keyword And Return Status    OperatingSystem.File Should Not Be Empty    ${path2FfExtension}
    ${path2ChromeExtension}=    Set Variable If    ${extensionPresente}    ${path2FfExtension}    ${EMPTY}

    # https://aerokube.com/selenoid/latest/#_downloading_files_in_different_browsers
    ${ff_profile}=      web.Definir Les Capacites Firefox
    ...    localBrowser=${False}
    ...    myAuthExtension=${path2ChromeExtension}
    ...    myDownloadDirectory=/home/selenium/Downloads

    # set selenoid browser version
    ${version}=    String.Fetch From Right  %{MY_BROWSER}  marker=:
    ${ff_capabilities}=     Create Dictionary  
    ...    enableVNC=${TRUE}
    ...    version=${version}
    ...    acceptInsecureCerts=${TRUE}

    SeleniumLibrary.Open Browser
    ...    alias=${myAlias}
    ...    remote_url=${SELENIUM_GRID.%{MY_ENV}}/wd/hub
    ...    desired_capabilities=${ff_capabilities}
    ...    ff_profile_dir=${ff_profile}

    SeleniumLibrary.Maximize Browser Window


Ouvrir ChromeDistant
    [Documentation]     Ouvrir Google Chrome de manière distante sur le device (aerokube selenoid).
    ...
    ...                 _Version Selenium._
    [Arguments]    ${myAlias}=None

    selenium.Initialiser Selenium
    # si une extension est presente dans TEMPDIR, l'ajouter dans chrome
    ${path2temp}=    Evaluate    tempfile.gettempdir()    modules=tempfile
    ${path2ChromeExtension}=    Set Variable    ${path2temp}/crx-auth.zip
    ${extensionPresente}=    Run Keyword And Return Status    OperatingSystem.File Should Not Be Empty    ${path2ChromeExtension}
    ${path2ChromeExtension}=    Set Variable If    ${extensionPresente}    ${path2ChromeExtension}    ${EMPTY}

    # https://aerokube.com/selenoid/latest/#_downloading_files_in_different_browsers
    ${chrome_options}=      web.Definir Les Capacites Chrome
    ...    localBrowser=${False}
    ...    myAuthExtension=${path2ChromeExtension}
    ...    myDownloadDirectory=/home/selenium/Downloads
    ${chrome_capabilities}=     Call Method     ${chrome_options}    to_capabilities

    ${version}=    String.Fetch From Right  %{MY_BROWSER}  marker=:
    Set To Dictionary       ${chrome_capabilities}    enableVNC=${true}    version=${version}
    SeleniumLibrary.Create WebDriver
    ...    Remote
    ...    alias=${myAlias} 
    ...    command_executor=${SELENIUM_GRID.%{MY_ENV}}/wd/hub
    ...    desired_capabilities=${chrome_capabilities}
    SeleniumLibrary.Maximize Browser Window
    SeleniumLibrary.Delete All Cookies
    
Ouvrir Chrome Avec Authentification Proxy
    [Documentation]     Start chrome browser.
    ...                 |   Based on https://stackoverflow.com/questions/37456794/chrome-modify-headers-in-selenium-java-i-am-able-to-add-extension-crx-through
    ...                 _Version Selenium._

    selenium.Initialiser Selenium
    # enable FlashPlayer and disable hardware acceleration (https://src.chromium.org/viewvc/chrome/trunk/src/chrome/common/pref_names.cc?view=markup)
    ${prefs}=       Create Dictionary    profile.default_content_setting_values.plugins=1    profile.content_settings.plugin_whitelist.adobe-flash-player=1    profile.content_settings.exceptions.plugins.*,*.per_resource.adobe-flash-player=1    download.default_directory=%{WORKSPACE}    hardware_acceleration_mode.enabled=1
    # launch webdriver with modHeader extension
    ${options}=    Evaluate      sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_extension    ${CURDIR}${/}..${/}resources${/}extensions${/}${WEB_PROXY_AUTH.crx}
    Call Method    ${options}    add_experimental_option    prefs    ${prefs}
    OperatingSystem.Set Environment Variable    PATH    %{PATH};${CURDIR}${/}..${/}resources${/}webdriver
    SeleniumLibrary.Create WebDriver        Chrome    chrome_options=${options}
    # setup extension to pass  proxy
    SeleniumLibrary.Go To                   chrome-extension://${WEB_PROXY_AUTH.modHeaderId}/icon.png
    SeleniumLibrary.Execute Javascript      localStorage.setItem('profiles', JSON.stringify([{title: 'Selenium', hideComment: true, appendMode: '',headers: [{enabled: true, name: '${WEB_PROXY_AUTH.name}', value: '${WEB_PROXY_AUTH.value}', comment: ''}],respHeaders: [],filters: []}]));
    SeleniumLibrary.Maximize Browser Window


Ouvrir Chrome Avec Profil
    [Documentation]     DEPRECATED - Ouvrir Chrome sur un profil utilisateur.
    ...
    ...                 *Arguments :*
    ...                 - ``myPath2Profile``      le chemin vers le profil à charger.
    ...                 _Version Selenium._
    [Arguments]         ${myPath2Profile}

    # on utilise le profile chrome  qui contient l'autentification dans l'extension "Modify Headers"
    ${options}=    Evaluate      sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_argument    --user-data-dir\=${myPath2profile}

    # Lancement du navigateur chrome
    log.Debug    Ouverture du navigateur Chrome sur le profil '${myPath2Profile}'
    SeleniumLibrary.Create WebDriver    Chrome    chrome_options=${options}
    SeleniumLibrary.Maximize Browser Window
    SeleniumLibrary.Delete All Cookies


Ouvrir Firefox
    [Arguments]    ${myAlias}=None
   
    # Selenium.Initialiser Selenium
    ${ff_profile}=      web.Definir Les Capacites Firefox
    
    ${options}=    Evaluate      sys.modules['selenium.webdriver'].FirefoxOptions()      sys, selenium.webdriver
    ${options.binary_location}=     Set Variable  /opt/firefox-107.0.1/firefox  #${WEB_PATH2CHROME} 
    ${options.headless} =     Set Variable  ${True}
    
    Open Browser
    ...  alias=${myAlias}
    ...  browser=firefox
    ...  ff_profile_dir=${ff_profile}
    ...  options=${options}

    # SeleniumLibrary.Maximize Browser Window

Ouvrir Firefox Avec BMP
    [Arguments]    ${myBrowser}

    # init BrowserMob Proxy, Automate HTTP Header Basic Authorization
    ${corporateProxy}=    Create Dictionary    httpProxy=%{MY_CORPPROXY}
    Start Local Server    ${WEB_PATH2BMP}
    ${BrowserMob_Proxy}=    Create Proxy    ${corporateProxy}
    ${auth}=    Create Dictionary    Authorization=Basic Z2VuZXJhbGk6Z2VuZXJhbGkyMDE4
    Set Headers    ${auth}
    ${monProxyUrl}    Get Proxy Url
    Log    ${monProxyUrl}
    # TODO pas de chemin absolu
    ${firefox_path}=    Set Variable    C:\\Users\\h0alt28\\Documents\\robot\\App\\FirefoxPortable\\FirefoxPortable.exe
    ${caps}=            Evaluate        sys.modules['selenium.webdriver'].common.desired_capabilities.DesiredCapabilities.FIREFOX    sys
    Collections.Set To Dictionary       ${caps}    marionette=${False}
    SeleniumLibrary.Create WebDriver    Firefox    firefox_binary=${firefox_path}    capabilities=${caps}    proxy=${BrowserMob_Proxy}
    SeleniumLibrary.Go To               about:config
    SeleniumLibrary.Maximize Browser Window
    SeleniumLibrary.Delete All Cookies
    New Har    %{BUILD_TAG}


Ouvrir Firefox Avec Authentification Proxy
    selenium.Initialiser Selenium
    # set a new firefox profile with    header_tool extension
    ${profile}=    Evaluate      sys.modules['selenium.webdriver'].FirefoxProfile()    sys, selenium.webdriver
    Call Method    ${profile}    add_extension    ${CURDIR}${/}..${/}resources${/}extensions${/}${WEB_PROXY_AUTH.xpi}
    # setup extension to pass  proxy
    Call Method    ${profile}    set_preference    extensions.headertool.preferencies.editor    ${WEB_PROXY_AUTH.name}:${WEB_PROXY_AUTH.value}@http://vm659.jn-hebergement.com
	Call Method    ${profile}    set_preference    browser.startup.homepage    about:blank
    Call Method    ${profile}    update_preferences
    # open Firefox with profile
    ${WEB_PROXY_AUTH.path2profile}=    Set Variable    ${profile.path}
  	SeleniumLibrary.Open Browser    about:blank    browser=firefox    alias=conquete    ff_profile_dir=${WEB_PROXY_AUTH.path2profile}
	SeleniumLibrary.Maximize Browser Window
    SeleniumLibrary.Delete All Cookies
    # Activate modify headers with keys    F4 + ALT+a + F4 (https://seleniumhq.github.io/selenium/docs/api/py/webdriver/selenium.webdriver.common.keys.html)
    SeleniumLibrary.Press Key    //body    u'\ue034'
    SeleniumLibrary.Press Key    //body    u'\ue00a'a
    SeleniumLibrary.Press Key    //body    u'\ue034'


Ouvrir IE
    [Arguments]    ${myAlias}=None
    Selenium.Initialiser Selenium
    SeleniumLibrary.Create WebDriver    Ie    ${myAlias}
    SeleniumLibrary.Maximize Browser Window


Ouvrir Internet Explorer
    [Arguments]    ${myAlias}=None
    Ouvrir IE    ${myAlias}


# ==============================================================================
# Se deplacer ==================================================================
# ==============================================================================
Aller Vers Le Site
    [Documentation]     Charger l'URL.
    ...
    ...                 *Arguments :*
    ...                 - ``myUri``             est l'URI vers laquelle se diriger.
    ...                 - ``myExpectedText``    est le texte attendu pour confirmer que la bonne page a été atteinte.
    ...                 - ``myTimeout``         est le temps d'attente maximum pour aller vers le site.
    ...                 _Version Selenium._
    [Arguments]         ${myUri}    ${myExpectedText}    ${myTimeout}=10s

    # Aiguillage vers le site de l'environnement de test choisi dans Jenkins - variable MY_ENV
    ${myUrl}=    web.obtenir url a partir uri    ${myUri}
    log.Debug           Je vais vers le site ${myUrl}
    Log  ${myUrl}
    SeleniumLibrary.Go To               ${myUrl}
    # On verifie la presence du titre de la page attendue en fonction de l'environnement
    SeleniumLibrary.Wait Until Page Contains    ${myExpectedText}       ${myTimeout}
    log.Debug                   La page contient le texte '${myExpectedText}'


Aller Vers Le Site En Utilisant L'URL Complete
    [Documentation]     Charger l'URL sans utiliser la variable MY_ENV.
    ...
    ...                 *Arguments :*
    ...                 - ``myUrl``             est l'URL vers laquelle se diriger.
    ...                 - ``myExpectedText``    est le texte attendu pour confirmer que la bonne page a été atteinte.
    ...                 - ``myTimeout``         est le temps d'attente maximum pour aller vers le site.
    ...                 _Version Selenium._
    [Arguments]         ${myUrl}    ${myExpectedText}    ${myTimeout}=10s

    log.Debug           Je vais vers le site ${myUrl}
    Log  ${myUrl}
    SeleniumLibrary.Go To               ${myUrl}
    # On verifie la presence du titre de la page attendue en fonction de l'environnement
    SeleniumLibrary.Wait Until Page Contains    ${myExpectedText}       ${myTimeout}
    log.Debug                   La page contient le texte '${myExpectedText}'


Naviguer Avec Le Browser Vers Le Site
    [Documentation]     Ouvrir le navigateur myBrowser ou MY_BROWSER par défaut, se positionner sur l'URL et vérifier la présence du texte sur la page.
    ...
    ...                 *Arguments :*
    ...                 - ``myUrl``             est l'URL vers laquelle se diriger.
    ...                 - ``myExpectedText``    est le texte attendu pour confirmer que la bonne page a été atteinte.
    ...                 - ``myBrowser``         est le navigateur à utiliser.
    ...                 _Version Selenium._
    [Arguments]         ${myUrl}    ${myExpectedText}    ${myBrowser}=%{MY_BROWSER}

    # forme de MY_BROWSER browser:version
    ${browser}=       String.Fetch From Left  ${myBrowser}    marker=:

    ${keywordWithBrowser}=    Set Variable    selenium.ouvrir ${browser}
    Run Keyword    ${keywordWithBrowser}
    selenium.Aller Vers Le Site    ${myUrl}    ${myExpectedText}


Naviguer Avec Le Browser Vers Le Site En Utilisant L'URL Complete
    [Documentation]     Ouvrir le navigateur myBrowser ou MY_BROWSER par défaut, se positionner sur l'URL et vérifier la présence du texte sur la page.
    ...
    ...                 *Arguments :*
    ...                 - ``myUrl``             est l'URL vers laquelle se diriger.
    ...                 - ``myExpectedText``    est le texte attendu pour confirmer que la bonne page a été atteinte.
    ...                 - ``myBrowser``         est le navigateur à utiliser.
    ...                 _Version Selenium._
    [Arguments]         ${myUrl}    ${myExpectedText}    ${myBrowser}=%{MY_BROWSER}    ${myAlias}=None

    ${keywordWithBrowser}=    Set Variable    selenium.Ouvrir ${myBrowser}
    Run Keyword    ${keywordWithBrowser}    ${myAlias}
    selenium.Aller Vers Le Site En Utilisant L'URL Complete    ${myUrl}    ${myExpectedText}

Naviguer Avec Le Browser Local Vers Le Site
    [Documentation]     Ouvrir le navigateur myBrowser ou MY_BROWSER par défaut, se positionner sur l'URL et vérifier la présence du texte sur la page.
    ...
    ...                 *Arguments :*
    ...                 - ``myUrl``             est l'URL vers laquelle se diriger.
    ...                 - ``myExpectedText``    est le texte attendu pour confirmer que la bonne page a été atteinte.
    ...                 - ``myBrowser``         est le navigateur à utiliser.
    ...                 _Version Selenium._
    [Arguments]         ${myUrl}    ${myExpectedText}    ${myBrowser}=%{MY_BROWSER}

    ${keywordWithBrowser}=    Set Variable    selenium.Ouvrir ${myBrowser}
    Run Keyword    ${keywordWithBrowser}
    selenium.Aller Vers Le Site    ${myUrl}    ${myExpectedText}


Naviguer Vers Le Site
    [Documentation]     Ouvrir le navigateur Chrome avec le profil, se positionner sur l'URL et vérifier la présence du texte sur la page.
    ...
    ...                 *Arguments :*
    ...                 - ``myUrl``             est l'URL vers laquelle se diriger.
    ...                 - ``myProfile``         est le profil à utiliser.
    ...                 - ``myExpectedText``    est le texte attendu pour confirmer que la bonne page a été atteinte.
    ...                 _Version Selenium._
    [Arguments]         ${myUrl}    ${myProfile}    ${myExpectedText}

    # on tente d'aller vers le site avec le navigateur existant
    ${estPass}=    Run Keyword And Return Status    selenium.aller vers le site    ${myUrl}    ${myExpectedText}
    # En cas d'echec, on lance le navigateur et on recommence
    Run Keyword Unless    ${estPass}    selenium.Ouvrir Chrome Avec Authentification Proxy
    Run Keyword Unless    ${estPass}    selenium.aller vers le site    ${myUrl}    ${myExpectedText}


Naviguer Vers Le Site Contenant Un Pdf
    [Documentation]     Ouvrir le navigateur Chrome avec le profil, se positionner sur l'URL et vérifier la présence du texte sur la page.
    ...
    ...                 *Arguments :*
    ...                 - ``myUrl``             est l'URL vers laquelle se diriger.
    ...                 - ``myExpectedText``    est le texte attendu pour confirmer que la bonne page a été atteinte.
    ...                 - ``myBrowser``         est le navigateur à utiliser.
    ...                 _Version Selenium._
    [Arguments]         ${myUrl}    ${myExpectedText}    ${myBrowser}=%{MY_BROWSER}

    ${keywordWithBrowser}=    Set Variable    selenium.ouvrir ${myBrowser} avec auth pour pdf
    Run Keyword    ${keywordWithBrowser}
    selenium.Aller Vers Le Site    ${myUrl}    ${myExpectedText}


Se Positionner Sur La Fenetre
    [Documentation]     Se positionner sur l'onglet correspondant.
    ...
    ...                 *Arguments :*
    ...                 - ``myTitle``       est l'onglet sur lequel il faut se positionner.
    ...                 _Version Selenium._
    [Arguments]         ${myTitle}

    #SeleniumLibrary.Select Window   title=${myTitle}
    SeleniumLibrary.Switch Window   locator=${myTitle}


# ==============================================================================
# Recuperer des donnees ========================================================
# ==============================================================================
Obtenir Mon Url
    [Documentation]     Obtenir l'URL courante.
    ...
    ...                 *Return* : l'adresse de la page actuelle.
    ...                 _Version Selenium Only._

    selenium.Confirmer Que La Page Est Prete
    ${currentLocation}    SeleniumLibrary.Get Location

    [Return]    ${currentLocation}


Obtenir Mon Titre
    [Documentation]     Obtenir le titre de la page courante.
    ...
    ...                 *Return* : le titre de la page actuelle.
    ...                 _Version Selenium Only._

    selenium.Confirmer Que La Page Est Prete
    ${title}    SeleniumLibrary.Get Title

    [Return]    ${title}


Obtenir La Cellule Du Tableau
    [Documentation]     Obtenir le contenu d'une cellule precise.
    ...
    ...                 *Arguments :*
    ...                 - ``myTBodyIdLocator``  est la localisation du tableau.
    ...                 - ``myRow``             est la ligne demandée.
    ...                 - ``myCol``             est la colonne demandée.
    ...                 *Return* : la valeur de la cellule.
    ...                 _Version Selenium Only._
    [Arguments]         ${myTBodyIdLocator}    ${myRow}    ${myCol}

    selenium.Confirmer Que La Page Est Prete
    ${cellLocator}=    Set Variable    //tbody[@id='${myTBodyIdLocator}']/tr[${myRow}]/td[${myCol}]
    ${cellValue}=    SeleniumLibrary.Get Text    ${cellLocator}

    [Return]    ${cellValue}


Obtenir Le Texte De L'Attribut
    [Documentation]     Obtenir le texte de l'attribut.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est la localisation de l'attribut.
    ...                 *Return* : la valeur de la cellule.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}    ${myAttribute}    ${myTimeout}=30s    ${myError}=None

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Wait Until Page Contains Element    ${myLocator}    ${myTimeout}    ${myError}
    ${attributeValue}=    SeleniumLibrary.Get Element Attribute    ${myLocator}    ${myAttribute}

    [Return]    ${attributeValue}



Obtenir Le Texte Complet De L'Element
    [Documentation]     _Version Selenium._
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est la localisation de l'élément.
    [Arguments]         ${myLocator}

    selenium.Confirmer Que La Page Est Prete
    selenium.La Page Contient L'Element    ${myLocator}
    ${cellValue}=    SeleniumLibrary.Execute Javascript    return document.evaluate("${myLocator}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.innerText;
  	${text}=    Set Variable    ${cellValue.replace("\n", " ")}
	${stripText}=    utils.Eliminer Les Espaces En Double    ${text}

    [Return]    ${stripText}


Obtenir Le Texte De L'Element
    [Documentation]     Obtenir le texte de l'élément qui doit être visible.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est la localisation de l'élément.
    ...                 *Return* : la valeur de la cellule.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}    ${myTimeout}=5s    ${myError}=None

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Wait Until Page Contains Element    ${myLocator}    ${myTimeout}    ${myError}
    ${cellValue}=    SeleniumLibrary.Get Text    ${myLocator}

    [Return]    ${cellValue}


Obtenir L'Element Le Plus Proche De La Liste
    [Documentation]     Obtenir l'élément le plus ressemblant de la liste.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``         est la localisation de la liste.
    ...                 - ``myExpectedOption``  est le choix attendu.
    ...                 - ``myTimeout``         est le temps d'attente maximum pour trouver le choix attendu.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}    ${myExpectedOption}    ${myTimeout}=30s

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Wait Until Element Is Enabled    ${myLocator}    ${myTimeout}
    SeleniumLibrary.Click Element    ${myLocator}
    ${options}=    Wait Until Keyword Succeeds    3x    200ms    Get List Items    ${myLocator}
    ${maxProximityOption}=    utils.Obtenir L'Element Le Plus Proche    ${myExpectedOption}    ${options}

    [Return]    ${maxProximityOption}


obtenir le nombre de ligne du tableau
    [Arguments]    ${myTableIdLocator}

    Selenium.Confirmer Que La Page Est Prete
    ${count}=  SeleniumLibrary.get element count  //table[@id='${myTableIdLocator}']/tbody/tr

    [Return]    ${count}


obtenir le nombre de ligne du tableau sans locator
    [Arguments]    ${myTablexpath}

    selenium.Confirmer Que La Page Est Prete
    ${count}=  SeleniumLibrary.get element count  ${myTablexpath}/tbody/tr

    [Return]    ${count}

obtenir le nombre d elements correspondants au locator
    [Arguments]    ${myXpath}

    selenium.Confirmer Que La Page Est Prete
    ${count}=  SeleniumLibrary.get element count  ${myXpath}

    [Return]    ${count}


obtenir la liste des elements correspondants au locator
    [Arguments]    ${myXpath}

    selenium.Confirmer Que La Page Est Prete
    selenium.La Page Contient L'Element        ${myXpath}
    ${returnItems}=    SeleniumLibrary.Get WebElements    ${myXpath}

    [Return]    ${returnItems}


obtenir la cellule du tableau hors entete
    [Arguments]    ${myTableIdLocator}    ${myRow}    ${myCol}

    Selenium.Confirmer Que La Page Est Prete
    ${cellValue}=    SeleniumLibrary.Get Table Cell    ${myTableIdLocator}    ${myRow}    ${myCol}

    [Return]    ${cellValue}


Le Texte De L'Element Doit Avoir La Valeur Attendue
    [Documentation]    Compare le texte de l'élément avec la valeur attendue
    [Arguments]    ${myLocator}     ${targetValue}

    ${textValue}=    selenium.Obtenir Le Texte De L'Element    ${myLocator}
    Run Keyword If	"""${textValue}""" != """${targetValue}"""    FAIL    msg=Le texte a la valeur "${textValue}" alors que la valeur attendue était "${targetValue}"


Le Texte De L'Element Doit Etre Conforme A L'Expression Reguliere
    [Documentation]    Compare le texte de l'élément avec l'expression régulière
    [Arguments]    ${myLocator}     ${myRegexp}

    ${textValue}=    selenium.Obtenir Le Texte De L'Element    ${myLocator}
    Should Match Regexp    ${textValue}    ${myRegexp}    msg=Le texte a la valeur "${textValue}" alors qu'il devait respecter l'expression régulière "${myRegexp}"


L'Element Doit Etre Desactive
    [Documentation]    Vérifie que l'élément est désactivé
    [Arguments]    ${myLocator}

    SeleniumLibrary.Element Should Be Disabled    ${myLocator}


# ==============================================================================
# Verifier l'etat de la page ===================================================
# ==============================================================================
La Page Doit Etre Prete
    [Documentation]     Verifier que la page est chargée.
    ...
    ...                 _Version Selenium._

    ${isReady}=    SeleniumLibrary.Execute Javascript    return document.readyState;
    Should Be Equal As Strings    ${isReady}    complete


Confirmer Que La Page Est Prete
    [Documentation]     Attendre que la page soit chargée.
    ...
    ...                 _Version Selenium._

    # Debug Purpose: selenium.capturer l'ecran
    Wait Until Keyword Succeeds    20s    1s    selenium.la page doit etre prete


La Page Ne Contient Pas L'Element
    [Documentation]     Vérifier que la page ne contient pas un élément.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est l'élément qui doit être absent.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}    ${myMessage}=None

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Page Should Not Contain Element    ${myLocator}    ${myMessage}


La Page Contient
    [Documentation]     Vérifier que la page contient un texte.
    ...
    ...                 *Arguments :*
    ...                 - ``myExpectedText``    est le texte attendu sur la page.
    ...                 - ``myTimeout``         est le temps d'attente maximum autorisé pour trouver le texte.
    ...                 _Version Selenium._
    [Arguments]         ${myExpectedText}    ${myTimeout}=30s    ${myError}=None

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Wait Until Page Contains    ${myExpectedText}    timeout=${myTimeout}    error=${myError}


La Page Contient L'Element
    [Documentation]     Verifier que la page contient un élément.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est l'élément qui doit être présent.
    ...                 - ``myTimeout``     est le temps d'attente maximum pour que l'élément apparaisse.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}    ${myTimeout}=30s    ${myError}=None

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Wait Until Page Contains Element    ${myLocator}    timeout=${myTimeout}    error=${myError}


La Page Contient L'Element Visible
    [Documentation]     Verifier que la page contient un élément visible.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est l'élément qui doit être présent.
    ...                 - ``myTimeout``     est le temps d'attente maximum pour que l'élément apparaisse.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}    ${myTimeout}=30s    ${myError}=None

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Wait Until Page Contains Element    ${myLocator}    timeout=${myTimeout}    error=${myError}
    SeleniumLibrary.Wait Until Element Is Visible  ${myLocator}    timeout=${myTimeout}    error=${myError}


Attendre La Disparition Element
    [Documentation]     Attendre qu'un élément disparaisse de la page.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est l'élément qui doit disparaître.
    ...                 - ``myTimeout``     est le temps d'attente maximum pour que l'élément disparaisse.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}    ${myTimeout}=180s

    # attendre une demi-seconde le temps que s'affiche la roue de generaiton
    Sleep    500ms
    SeleniumLibrary.Wait Until Element Is Not Visible     ${myLocator}    ${myTimeout}


L'element n'est pas visible sur la page
    [Documentation]  Verifie que l'element n'est plus visible sur la page avant le timeout
    [Arguments]    ${myLocator}    ${timeout}=30s

	SeleniumLibrary.Wait Until Element Is Not Visible    ${myLocator}    timeout=${timeout}


Verifier le titre de la page
    [Documentation]  Verifie que le titre de la page correspond bien a la valeur attendue
    [Arguments]     ${myTitle}    ${myMessage}=None

    SeleniumLibrary.Title Should Be     ${myTitle}    ${myMessage}


L'url de la page doit avoir la valeur attendue
    [Documentation]  Compare l'url de la page active avec la valeur attendue
    [Arguments]     ${urlAttendu}

    ${urlObtenu}=	Selenium.obtenir mon url
    SeleniumLibrary.Location Should Be    ${urlAttendu}    message=L'url de la page ${urlObtenu} est differente de l'url attendue ${urlAttendu}

    # A supprimer
    #Run Keyword If	"${currentUrl}" != "${targetValue}"		FAIL    msg=L'url de la page ${currentUrl} est differente de l'url attendue ${targetValue}


# ==============================================================================
# Choisir un element ===========================================================
# ==============================================================================
Choisir Le Fichier
    [Documentation]     Choisir un fichier en indiquant son chemin d'accès.
    ...
    ...                 *Arguments :*
    ...                 - ``myXpathLocator``    ?
    ...                 - ``myPath2file``       est le chemin vers le fichier.
    ...                 _Version Selenium Only._
    [Arguments]         ${myXpathLocator}    ${myPath2file}    ${myTimeout}=30s

    selenium.Confirmer Que La Page Est Prete
    log.Debug    Saisir le fichier '${myPath2file}'
    SeleniumLibrary.Choose File    ${myXpathLocator}    ${myPath2file}

Choisir Dans La Liste
    [Documentation]     Faire un choix dans une liste déroulante.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est la localisation de la liste.
    ...                 - ``myOption``      est l'élément à selectionner dans la liste déroulante.
    ...                 - ``myTimeout``     est le temps d'attente maximum pour trouver l'élément.
    ...                 _Version Selenium Only._
    [Arguments]         ${myLocator}    ${myOption}    ${myTimeout}=30s

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Wait Until Element Is Enabled   ${myLocator}    ${myTimeout}
    ${optionProche}=    web.Obtenir L'Element Le Plus Proche De La Liste    ${myLocator}    ${myOption}
    SeleniumLibrary.Select From List By Label       ${myLocator}    ${optionProche}

Double Cliquer Sur Element Visible Et Actif
    [Documentation]     Cliquer sur un élément visible et actif sur la page.
    ...
    ...                 *Arguments :*
    ...                 - ``myXpathLocator``    est l'élément sur lequel on veut cliquer.
    ...                 - ``myTimeout``         est le temps d'attente maximum pour trouver l'élément.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}    ${myTimeout}=30s   ${myError}=None

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Wait Until Element Is Visible    ${myLocator}    ${myTimeout}    ${myError}
    SeleniumLibrary.Wait Until Element Is Enabled    ${myLocator}    ${myTimeout}    ${myError}
    selenium.Double Cliquer Sur Element Avec Webdriver    ${myLocator}


Double Cliquer Sur Element Avec Webdriver
    [Documentation]     Cliquer sur un élément avec le webdriver sans vérification préalable.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est l'élément sur lequel on veut cliquer.
    ...                 Version Selenium.
    [Arguments]         ${myLocator}   

    Wait until keyword succeeds    3x    1s    SeleniumLibrary.Double Click Element           ${myLocator}


Double Cliquer Sur Element Visible Et Actif Avec Javascript
    [Documentation]     Cliquer sur un élément visible et actif sur la page.
    ...
    ...                 *Arguments :*
    ...                 - ``myXpathLocator``    est l'élément sur lequel on veut cliquer.
    ...                 - ``myTimeout``         est le temps d'attente maximum pour trouver l'élément.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}    ${myTimeout}=30s   ${myError}=None

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Wait Until Element Is Enabled    ${myLocator}    ${myTimeout}    ${myError}
    SeleniumLibrary.Wait Until Element Is Visible    ${myLocator}    ${myTimeout}    ${myError}
    selenium.Double Cliquer Sur Element Avec Javascript    ${myLocator}


Choisir Dans La Liste Par Valeur
    [Documentation]     Faire un choix dans une liste déroulante.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est la localisation de la liste.
    ...                 - ``myOption``      est l'élément à selectionner dans la liste déroulante.
    ...                 - ``myTimeout``     est le temps d'attente maximum pour trouver l'élément.
    ...                 _Version Selenium Only._
    [Arguments]         ${myLocator}    ${myOption}    ${myTimeout}=30s

    selenium.Confirmer Que La Page Est Prete
    log.Debug    Choisir ${myOption}
    SeleniumLibrary.Wait Until Element Is Enabled   ${myLocator}    ${myTimeout}
    SeleniumLibrary.Select From List By Value       ${myLocator}    ${myOption}

Choisir Dans La Liste Unique
    [Documentation]     _Version Selenium Only._
    [Arguments]         ${myLocator}    # l'élément que l'on veut sélectionner dans la liste déroulante est unique

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Wait Until Element Is Enabled    ${myLocator}
    SeleniumLibrary.Select From List    ${myLocator}
    Sleep    3s


Choisir Bouton Radio
    [Documentation]     Sélectionner un bouton radio.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est l'ensemble des boutons radios existants.
    ...                 - ``myChoice``      est le bouton radio à sélectionner.
    ...                 _Version Selenium Only._
    [Arguments]         ${myLocator}    ${myChoice}

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Select Radio Button    ${myLocator}    ${mychoice}


Le Bouton Radio Doit Etre Selectionne
    [Documentation]     S'assurer que le bouton radio est sélectionné'.
    ...
    ...                 *Arguments :*
    ...                 - ``myName``     est le nom du groupe de choix possible (name).
    ...                 - ``myValue``      est le bouton radio qui doit être sélectionné.
    ...                 _Version Selenium Only._
    [Arguments]         ${myName}    ${myValue}

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Wait Until Page Contains Element    ${myName}
    SeleniumLibrary.Radio Button Should Be Set To    ${myName}    ${myValue}


Le Bouton Radio Ne Doit Pas Etre Selectionne
    [Documentation]     S'assurer que le bouton radio n'est pas sélectionné'.
    ...
    ...                 *Arguments :*
    ...                 - ``myName``     est le nom du groupe de choix possible (name).
    ...                 _Version Selenium Only._
    [Arguments]         ${myName}

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Wait Until Page Contains Element    ${myName}
    SeleniumLibrary.Radio Button Should Not Be Selected    ${myName}


Cocher Un Element
    [Documentation]     Cocher un élément sur une page.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est la checkbox à cocher.
    ...                 _Version Selenium Only._
    [Arguments]         ${myLocator}    ${myTimeout}=5s    ${myError}=None

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Wait Until Element Is Enabled    ${myLocator}    ${myTimeout}    ${myError}
    SeleniumLibrary.Select Checkbox    ${myLocator}


Decocher Un Element
    [Documentation]     Cocher un élément sur une page.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est la checkbox à cocher.
    ...                 _Version Selenium Only._
    [Arguments]         ${myLocator}

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Wait Until Element Is Enabled    ${myLocator}
    SeleniumLibrary.Unselect Checkbox    ${myLocator}


# ==============================================================================
# Saisir du texte ==============================================================
# ==============================================================================
Saisir Un Secret Dans Element Actif
    [Documentation]     Saisir du texte non enregistre dans un élément.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est l'élément dans lequel le texte sera saisi.
    ...                 - ``myText``        est le texte à saisir.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}    ${myText}    ${myTimeout}=5s    ${myError}=None

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Wait Until Element Is Enabled    ${myLocator}    ${myTimeout}    ${myError}
    SeleniumLibrary.Wait Until Element Is Visible    ${myLocator}    ${myTimeout}    ${myError}
    selenium.Saisir Un Secret Avec Webdriver    ${myLocator}      ${myText}


Saisir Dans Element Actif Et Sortir Du Champ
    [Documentation]     Saisir du texte dans un élément puis quitter le champ.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est l'élément dans lequel le texte sera saisi.
    ...                 - ``myText``        est le texte à saisir.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}     ${myText}

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Wait Until Element Is Enabled   ${myLocator}
    log.Debug       Saisir le texte '${myText}'
    selenium.Saisir Avec Webdriver                  ${myLocator}    ${myText}
    # Tabulation pour sortir du champ
    selenium.Appuyer Sur Une Touche      ${myLocator}    u'\ue004'


Appuyer Sur Une Touche
    [Documentation]     Appuyer sur une touche du clavier.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est l'élément dans lequel la touche sera appuyée.
    ...                 - ``myAsciiCode``   est le code ASCII de la touche sur laquelle on veut appuyer.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}    ${myAsciiCode}

    SeleniumLibrary.Press Key    ${myLocator}    ${myAsciiCode}


Appuyer Sur des Touches
    [Documentation]     Appuyer sur des Touches du clavier.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est l'élément dans lequel les touches seront appuyée.
    ...                 - ``myAsciiCode``   est le code ASCII des  touches sur laquelles on veut appuyer.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}    ${myAsciiCode}

    SeleniumLibrary.Press keys    ${myLocator}    ${myAsciiCode}


Saisir Dans Element Actif
    [Documentation]     Saisir du texte dans un élément.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est l'élément dans lequel le texte sera saisi.
    ...                 - ``myText``        est le texte à saisir.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}    ${myText}    ${myTimeout}=5s    ${myError}=None

    selenium.Confirmer Que La Page Est Prete
    log.Debug    Saisir le texte '${myText}'
    SeleniumLibrary.Wait Until Element Is Enabled    ${myLocator}    ${myTimeout}    ${myError}
    SeleniumLibrary.Wait Until Element Is Visible    ${myLocator}    ${myTimeout}    ${myError}
    selenium.Saisir Avec Webdriver    ${myLocator}   ${myText}


Saisir Dans Element Actif Avec Javascript
    [Documentation]     Saisir du texte dans un élément via Javascript.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est l'élément dans lequel le texte sera saisi.
    ...                 - ``myText``        est le texte à saisir.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}    ${myText}    ${myAttribute}=value    ${myTimeout}=5s    ${myError}=None

    selenium.Confirmer Que La Page Est Prete
    log.Debug    Saisir le texte '${myText}'
    SeleniumLibrary.Wait Until Element Is Enabled    ${myLocator}    ${myTimeout}    ${myError}
    SeleniumLibrary.Wait Until Element Is Visible    ${myLocator}    ${myTimeout}    ${myError}
    selenium.Saisir Avec Javascript    ${myLocator}    ${myText}    ${myAttribute}


Saisir Dans Element Actif Sans Effacer L'Existant
    [Documentation]     Saisir du texte dans un élément à la suite de ce qui est déjà présent.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est l'élément dans lequel le texte sera saisi.
    ...                 - ``myText``        est le texte à saisir.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}    ${myText}    ${myTimeout}=5s    ${myError}=None

    selenium.Confirmer Que La Page Est Prete
    log.Debug    Saisir le texte '${myText}'
    SeleniumLibrary.Wait Until Element Is Enabled    ${myLocator}    ${myTimeout}    ${myError}
    SeleniumLibrary.Wait Until Element Is Visible    ${myLocator}    ${myTimeout}    ${myError}
    selenium.Saisir Avec Webdriver    ${myLocator}   ${myText}    False


Saisir Avec Webdriver
    [Documentation]     Saisir du texte dans un élément directement depuis le webdriver.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est l'élément dans lequel le texte sera saisi.
    ...                 - ``myText``        est le texte à saisir.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}    ${myText}    ${myClear}=True

    SeleniumLibrary.Input Text    ${myLocator}    ${myText}    ${myClear}


Saisir Un Secret Avec Webdriver
    [Documentation]     Saisir du texte non enregistré dans un élément directement depuis le webdriver.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est l'élément dans lequel le texte sera saisi.
    ...                 - ``myText``        est le texte à saisir.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}    ${myText}

    SeleniumLibrary.Input Password    ${myLocator}    ${myText}


Saisir Avec Javascript
    [Documentation]     Saisir du texte dans un élément en utilisant un script.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est l'élément dans lequel le texte sera saisi.
    ...                 - ``myText``        est le texte à saisir.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}    ${myText}    ${myAttribute}=value

    Execute Javascript    document.evaluate("${myLocator}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.setAttribute('${myAttribute}', '${myText}');


Saisir Avec Script
    [Documentation]     Saisir du texte dans un élément en utilisant un script.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est l'élément dans lequel le texte sera saisi.
    ...                 - ``myText``        est le texte à saisir.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}    ${myText}

    Execute Javascript    document.evaluate("${myLocator}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.setAttribute('value', '${myText}');


Effacer Dans Element Actif
    [Documentation]     Effacer du texte dans un élément.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``       est l'élément dans lequel le texte effacé.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}    ${myTimeout}=30s    ${myError}=None

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Wait Until Element Is Enabled    ${myLocator}    ${myTimeout}    ${myError}
    SeleniumLibrary.Wait Until Element Is Visible    ${myLocator}    ${myTimeout}    ${myError}
    SeleniumLibrary.Clear Element Text    ${myLocator}


# ==============================================================================
# Cliquer ======================================================================
# ==============================================================================
Cliquer Sur Element Visible
    [Documentation]     Cliquer sur un élément visible sur la page.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est l'élément sur lequel cliquer.
    ...                 - ``myTimeout``     est le temps d'attente maximum pour trouver l'élément.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}     ${myTimeout}=30s

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Wait Until Element Is Visible    ${myLocator}    ${myTimeout}
    selenium.Confirmer Que La Page Est Prete
    selenium.Cliquer Sur Element Avec Webdriver    ${myLocator}


Cliquer Sur Element actif
    [Documentation]     Cliquer sur un élément actif sur la page.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est l'élément sur lequel cliquer.
    ...                 - ``myTimeout``     est le temps d'attente maximum pour trouver l'élément.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}    ${myTimeout}=30s

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Wait Until Element Is Enabled    ${myLocator}    ${myTimeout}
    selenium.Cliquer Sur Element Avec Webdriver    ${myLocator}


Cliquer Sur Element Visible Et Actif
    [Documentation]     Cliquer sur un élément visible et actif sur la page.
    ...
    ...                 *Arguments :*
    ...                 - ``myXpathLocator``    est l'élément sur lequel on veut cliquer.
    ...                 - ``myTimeout``         est le temps d'attente maximum pour trouver l'élément.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}    ${myTimeout}=30s   ${myError}=None

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Wait Until Element Is Visible    ${myLocator}    ${myTimeout}    ${myError}
    SeleniumLibrary.Wait Until Element Is Enabled    ${myLocator}    ${myTimeout}    ${myError}
    selenium.Cliquer Sur Element Avec Webdriver    ${myLocator}


Cliquer Sur Element Visible Et Actif Avec Javascript
    [Documentation]     Cliquer sur un élément visible et actif sur la page.
    ...
    ...                 *Arguments :*
    ...                 - ``myXpathLocator``    est l'élément sur lequel on veut cliquer.
    ...                 - ``myTimeout``         est le temps d'attente maximum pour trouver l'élément.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}    ${myTimeout}=30s   ${myError}=None

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Wait Until Element Is Enabled    ${myLocator}    ${myTimeout}    ${myError}
    SeleniumLibrary.Wait Until Element Is Visible    ${myLocator}    ${myTimeout}    ${myError}
    selenium.Cliquer Sur Element Avec Javascript    ${myLocator}


Cliquer Sur Element visible et actif apres la disparition d'un autre element qui le cache
    [Documentation]  Clique sur l'element apres la disparition d'un autre qui le cache
    [Arguments]    ${myLocatorClick}    ${myLocatorElementQuiCache}    ${myTimeout}=30s

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Wait Until Element Is Not Visible      ${myLocatorElementQuiCache}
    SeleniumLibrary.Wait Until Element Is Enabled    ${myLocatorClick}    ${myTimeout}
    SeleniumLibrary.Wait Until Element Is Visible    ${myLocatorClick}    ${myTimeout}
    SeleniumLibrary.Click Element    ${myLocatorClick}


Cliquer Sur Element visible et actif le plus a gauche possible
    [Documentation]  Clique sur la zone la plus a gauche possible de l'element
    [Arguments]    ${myLocator}    ${myTimeout}=30s

    selenium.Confirmer Que La Page Est Prete
    ${width}	${height}=	SeleniumLibrary.Get Element Size	${myLocator}
    ${var}=		Evaluate	-(${width}/2)+1
    SeleniumLibrary.Wait Until Element Is Enabled    ${myLocator}    ${myTimeout}
    SeleniumLibrary.Wait Until Element Is Visible    ${myLocator}    ${myTimeout}
    SeleniumLibrary.Click Element At Coordinates      ${myLocator}		${var}       0


Cliquer Sur Element visible et actif en maintenant des touches
    [Documentation]  Clique sur l'element en maintenant une ou plusieurs touches du clavier
    [Arguments]    ${myLocator}    ${myKeys}   ${myTimeout}=30s

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Wait Until Element Is Enabled    ${myLocator}    ${myTimeout}
    SeleniumLibrary.Wait Until Element Is Visible    ${myLocator}    ${myTimeout}
    selenium.Cliquer Sur Element Avec Webdriver    ${myLocator}    ${myKeys}


Cliquer Sur Element Avec Webdriver
    [Documentation]     Cliquer sur un élément avec le webdriver sans vérification préalable.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est l'élément sur lequel on veut cliquer.
    ...                 Version Selenium.
    [Arguments]         ${myLocator}    ${myModifier}=False

    Wait until keyword succeeds    3x    1s    SeleniumLibrary.Click Element           ${myLocator}    ${myModifier}


Cliquer Sur Element Avec Javascript
    [Documentation]     Cliquer sur un élément en utilisant javascript.
    ...
    ...                 *Arguments :*
    ...                 - ``myLocator``     est l'élément sur lequel on veut cliquer.
    ...                 _Version Selenium._
    [Arguments]         ${myLocator}    ${myTimeout}=30s

    selenium.Confirmer Que La Page Est Prete
    SeleniumLibrary.Execute Javascript      document.evaluate("${myLocator}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click();
    selenium.Confirmer Que La Page Est Prete


Accepter La Popup
    [Documentation]    Accepte la Pop-up qui apparaît à l'écran et retourne le message qu'elle affiche
    [Arguments]    ${myTimeout}=30s

    ${myMessage}=    SeleniumLibrary.Handle Alert    ACCEPT    ${myTimeout}

    [Return]    ${myMessage}


Verifier Le Message De La Popup Et L'Accepter
    [Documentation]    Vérifie le message de la Pop-up qui apparaît à l'écran et l'accepter
    ...
    ...                 *Arguments :*
    ...                 - ``myMessage``     est le message que l'on veut vérifier.
    ...                 - ``myTimeout``     est le temps d'attente maximum pour trouver l'élément.
    ...                 _Version Selenium._
    [Arguments]         ${myMessage}    ${myTimeout}=30s

    SeleniumLibrary.Alert Should Be Present    ${myMessage}    ACCEPT    ${myTimeout}


# ==============================================================================
# Generalites ==================================================================
# ==============================================================================
Capturer L'Ecran
    [Documentation]     Faire une capture d'écran de la page actuelle.
    ...
    ...                 _Version Selenium._

    SeleniumLibrary.Capture Page Screenshot


Capture L'Ecran Avec Timestamp Pour Nom De Fichier
    [Documentation]   Réalise une capture d'écran avec un timestamp pour nom de fichier
    ${date}=    Get Current Date    result_format=%d-%m-%Y %Hh%Mm%Ss   exclude_millis=True
    ${title}=  get title
    ${page_title}=  remove string  ${title}  ,  ?  .  ;  /  :  §  !  %  *  $  \
    SeleniumLibrary.Capture Page Screenshot   ${date}_${page_title}.png


Capture L'Ecran Avec Timestamp Pour Page Identifier De Fichier
    [Documentation]   Réalise une capture d'écran avec un timestamp pour nom de fichier
    ${date}=    Get Current Date    result_format=%d-%m-%Y %Hh%Mm%Ss   exclude_millis=True
    ${page_title}=  get title
    ${page_identifier}=  get text  //*[@id="pageIdentifier"]/samp
    SeleniumLibrary.Capture Page Screenshot   ${date}_${page_identifier}_${page_title}.png

Fixer Le Zoom
    [Documentation]     Effectuer un zoom sur la page.
    ...
    ...                 *Arguments :*
    ...                 - ``myZoom`` est la puissance du zoom à effectuer.
    ...                 _Version Selenium._
    [Arguments]         ${myZoom}

    SeleniumLibrary.Execute javascript    document.body.style.zoom="${myZoom}%"
    # TODO - Non operationnel - BrowserMobProxy avec container docker en PreRequis car necessite de modifier le proxy settings windows


Fermer Tous Les Navigateurs
    [Documentation]     Fermer tous les navigateurs ouverts.
    ...
    ...                 _Version Selenium._


    # fermer les navigateurs ouverts uniquement
    ${browsers}=    SeleniumLibrary.Get Browser Ids
    ${isOpenBrowser}=    Get Length    ${browsers}
    Run Keyword If    ${isOpenBrowser} > 0    SeleniumLibrary.Close All Browsers

    # supprimer le profile firefox si necessaire
#  	${passed}    ${length}=          Run Keyword And Ignore Error    Get Length    ${WEB_PROXY_AUTH.path2profile}
#  	${isSet}=                        Set Variable If    '${passed}'=='FAIL'    0    ${length}
#    Run Keyword If    ${isSet} > 0   Remove Directory    ${WEB_PROXY_AUTH.path2profile}    recursive=${TRUE}


Actualiser la page
    [Documentation]  Actualise la page active du navigateur

    SeleniumLibrary.Reload Page


Fermer l'onglet du navigateur
    [Documentation]  Ferme l'onglet actif du navigateur

    SeleniumLibrary.Close Window


Changer De Navigateur
    [Documentation]     Changer de navigateur.
    ...
    ...                 *Arguments :*
    ...                 - ``myIndex``   est le nouveau navigateur à ouvrir.
    ...                 _Version Selenium Only._
    [Arguments]         ${myIndex}

    SeleniumLibrary.Switch Browser    ${myIndex}


Positionner le curseur sur un element
    [Documentation]  Positionne le curseur de la souris au dessus d'un element
    [Arguments]  ${myLocator}

    SeleniumLibrary.Wait Until Element Is Visible  ${myLocator}
    SeleniumLibrary.Mouse Over  ${myLocator}


Selectionner La Frame
    [Documentation]  Selectionne la frame ou l'iframe
    [Arguments]  ${myLocator}

    SeleniumLibrary.Select Frame    ${myLocator}


Deselectionner La Frame
    [Documentation]  Deselectionne la frame ou l'iframe

    SeleniumLibrary.Unselect Frame


Selectionner La Nouvelle Fenetre
    [Documentation]  Selectionne la derniere fenetre ouverte

    Wait Until Keyword Succeeds  5x  1s  Selenium.Plusieurs fenetres doivent etre presentes
    SeleniumLibrary.Switch Window    New


Plusieurs fenetres doivent etre presentes

    ${id_list}=    SeleniumLibrary.Get Window Names
    ${count}=    Get Length  ${id_list}
    Should Be True    ${count} > 1


Mettre le robot en pause
    [Documentation]  Met le robot en pause
    [Arguments]     ${message}
    Execute Manual Step  ${message}

Se Positionner Sur L'Element
    [Documentation]    Scroll de la page jusqu'à l'element
    [Arguments]    ${my_locator}

    SeleniumLibrary.Execute Javascript
    ...  return document.evaluate("${my_locator}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoView();
