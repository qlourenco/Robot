# -*- coding: utf-8 -*-
*** Settings ***
Documentation       Gestionnaire de logs.
...
...                 Cette librairie a pour utilité de concevoir des logs de différentes
...                 couleurs selon leur niveau d'importance. Par exemple, un log indiquant un
...                 succès (_success_) s'affichera en vert et un log indiquant un échec
...                 (_fail_), affichera un log en rouge.

Library             DateTime
Library             OperatingSystem


*** Variables ***
#ansi codes
&{LOG_COLORS}    bold="\\033[1m"
...              normal="\\033[0m"
...              black="\\033[30m"
...              red="\\033[31m"
...              green="\\033[32m"
...              yellow="\\033[33m"
...              blue="\\033[34m"
...              magenta="\\033[35m"
...              cyan="\\033[36m"
...              grey="\\033[37m"


*** Keywords ***
Creer Un Rapport De Capture
    [Documentation]     Construire un rapport de capture au format HTML.

    @{img}=    OperatingSystem.List Files In Directory    %{WORKSPACE}    pattern=*png
    # trier la liste humainement
    #autowin.trier humainement les captures    ${img}
    Log    ${img}
    ${html}=    Set Variable    <html><header><meta charset="utf-8" /><title>Rapport des captures</title></header><body><h1>%{JOB_NAME}</h1><br><br><h3>Rapport des captures ayant ete prise par le robot</h3><br><br><h3>Execute sur : %{NODE_NAME}</h3><br><br>
    FOR    ${ELEMENT}    IN    @{img}
        ${html}=    Set Variable    ${html}<br><center><b>${ELEMENT}</b><br><br><img src='${ELEMENT}' border="3"/><br>
    END
    ${html}=    Set Variable    ${html}</body></html>
    # Publier le rapport dans le workspace du job
    OperatingSystem.Create File    %{WORKSPACE}/captureViewer.html    content=${html}
    # Publier dans console output
    log.Info    \nPour acceder aux captures d ecran faites par le robot cliquez sur le lien ci dessous :
    Log To Console    Lien : %{JENKINS_URL}job/%{JOB_NAME}/%{BUILD_NUMBER}/robot/report/captureViewer.html


Mettre En Couleur
    [Documentation]     Mettre un log en couleur dans la console durant l'exécution.
    ...
    ...                 *Arguments :*
    ...                 - ``myColor``       est la couleur du log a definir.
    ...                 - ``myMessage``     est le message a afficher dans la console.
    ...                 - ``myLevel``       est le niveau d'importance du log a afficher.
    [Arguments]         ${myColor}    ${myMessage}    ${myLevel}

    # Definition des couleurs du texte
    ${e_color}=    Evaluate    ${LOG_COLORS.${myColor}}
    ${default}=    Evaluate    ${LOG_COLORS.normal}
    # Estampille du message
    ${date} =    obtenir timestamp
    # On colorise au besoin
    ${log}=    Set Variable    ${date} [${e_color}${myLevel}${default}] ${e_color}${myMessage}${default}
    # On affiche le log en console
    ${RF_level}=    Set Variable If    '${myLevel}'=='SUCCESS'    INFO    ${myLevel}
    Log    ${log}    level=${RF_level}    html=true    console=true


Obtenir Timestamp
    [Documentation]     Obtenir l'heure courante.
    ...
    ...                 *Return* : l'heure sous le format année/mois/jour heure/minute/seconde.

    ${timeStamp}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S

    [Return]    ${timeStamp}


Info
    [Documentation]     Créer un log d'information.
    ...
    ...                 *Arguments :*
    ...                 - ``myMessage``     est le message à afficher.
    [Arguments]         ${myMessage}

    mettre en couleur    cyan    ${myMessage}    INFO


Success
    [Documentation]     Créer un log de succès.
    ...
    ...                 *Arguments :*
    ...                 - ``myMessage``     est le message à afficher.
    [Arguments]         ${myMessage}

    mettre en couleur    green    ${myMessage}  SUCCESS


Warning
    [Documentation]     Créer un log de mise en garde.
    ...
    ...                 *Arguments :*
    ...                 - ``myMessage``     est le message à afficher.
    [Arguments]         ${myMessage}

    mettre en couleur    yellow    ${myMessage}    WARN


Error
    [Documentation]     Créer un log d'erreur.
    ...
    ...                 *Arguments :*
    ...                 - ``myMessage``     est le message à afficher.
    [Arguments]         ${myMessage}

    mettre en couleur    red    ${myMessage}   ERROR


Debug
    [Documentation]     Créer un log de débogage.
    ...
    ...                 *Arguments :*
    ...                 - ``myMessage`` est le message à afficher.
    [Arguments]         ${myMessage}

    mettre en couleur    grey    ${myMessage}    DEBUG
