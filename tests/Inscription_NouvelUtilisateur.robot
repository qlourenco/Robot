*** Settings ***
Documentation     Test d'inscription d'un nouveau utilisateur

Variables         ../Variables.yaml

Resource          ../ressources/gherkin.robot

Library           DataDriver    file=%{MY_DATASET}    sheet_name=TEST

Test Setup       Run Keywords    web.Ouvrir Chrome
...              AND    SeleniumLibrary.Go To   ${URL}

Test Teardown     web.Fermer Tous Les Navigateurs

*** Test Cases ***
Inscription d'un nouvel utilisateur
    [Documentation]     Un nouveau utilisateur doit pouvoir s'inscrire sur le site
    [Tags]              TNR INS
    [Template]          Inscription d'un nouvel utilisateur
  
*** Keywords ***
Inscription d'un nouvel utilisateur
    [Documentation]     Un nouveau utilisateur doit pouvoir s'inscrire sur le site
    [Tags]              TNR INS
    [Arguments]         ${THE_DATA}
    
    Given un utilisateur inconnu veut s'inscrire en arrivant sur le site    ${THE_DATA}
    When l'utilisateur remplit le formulaire d'inscription
    Then il doit être inscrit sur le site