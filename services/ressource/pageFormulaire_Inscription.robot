*** Settings ***
Documentation     Keywords de la page du formulaire

Resource    ../../socle/ressources/utils.robot
Resource    ../../socle/ressources/web.robot

*** Keywords ***
Renseignement des informations personnelles dans le formulaire
    [Documentation]     L'utilisateur renseigne les informations personnelles dans le formulaire
    [Arguments]     ${my_user}

    Je remplis le champ "firstname"    ${my_user}
    Je remplis le champ "lastname"    ${my_user}
    Je remplis le champ "email"    ${my_user}
    Je remplis le champ "password"    ${my_user}
    Cliquer sur le bouton "submit"

Cliquer sur le bouton "submit"
    [Documentation]     L'utilisateur clique sur le bouton submit
    
    web.Cliquer Sur Element Actif    xpath=//*[@id="submit"]

Je suis sur la page du formulaire
    [Documentation]     L'utilisateur se trouve sur la page de formulaire

    web.Le Texte De L'Element Doit Avoir La Valeur Attendue    xpath=/html/body/div[1]/h1    Add User
    Log    La page de formulaire est bien Visible

Je ne suis plus sur la page du formulaire
    [Documentation]     L'utilisateur ne se trouve plus sur la page de formulaire

    web.l'element n'est plus visible sur la page    xpath=//*[@id="submit"]
    Log    La page de formulaire n'est plus Visible

Je remplis le champ "firstname"
    [Documentation]     L'utilisateur remplit le champ firstname avec la valeur
    [Arguments]     ${my_user}
    
    web.Saisir Dans Element Actif    xpath=//*[@id="firstName"]    ${my_user.firstname}

Je remplis le champ "lastname"
    [Documentation]     L'utilisateur remplit le champ lastname avec la Valeur
    [Arguments]     ${my_user}
    
    web.Saisir Dans Element Actif    xpath=//*[@id="lastName"]    ${my_user.lastname}

Je remplis le champ "email"
    [Documentation]     L'utilisateur remplit le champ email avec la valeur
    [Arguments]     ${my_user}

    web.Saisir Dans Element Actif    xpath=//*[@id="email"]    ${my_user.email}

Je remplis le champ "password"
    [Documentation]     L'utilisateur remplit le champ password avec la valeur
    [Arguments]     ${my_user}
    
    web.Saisir Dans Element Actif    xpath=//*[@id="password"]    ${my_user.password}

