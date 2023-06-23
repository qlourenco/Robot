*** Settings ***
Documentation     Test d'inscription d'un nouveau utilisateur

Variables         ../Variables.yaml

Resource          ../ressources/gherkin.robot

Library           DataDriver    file=%{MY_DATASET}    sheet_name=TEST2

Test Setup       Run Keywords    web.Ouvrir Chrome
...               AND    SeleniumLibrary.Go To   ${URL}

Test Teardown     web.Fermer Tous Les Navigateurs

Test Template     Ajouter un nouveau contact

*** Test Cases ***
TC1 - Ajout d'un nouveau contact
    [Documentation]      En tant qu'utilisateur je peux ajouter un nouveau contact 
    [Tags]               TNR AUTH

*** Keywords ***
Ajouter un nouveau contact
    [Documentation]    Ajouter un nouveau contact
    [Tags]    TNR AUTH
    [Arguments]     ${THE_DATA}
    
    Given un utilisateur connecté    ${THE_DATA}
    When l'utilisateur ajoute un nouveau contact
    Then le contact doit être créé