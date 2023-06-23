*** Settings ***
Documentation     Keywords de la page de connexion

Resource    ../../socle/ressources/utils.robot
Resource    ../../socle/ressources/web.robot

*** Keywords ***
Authentification
    [Documentation]     Authentification de l'utilisateur
    [Arguments]     ${my_user}

    Je remplis le champ "email"    ${my_user}
    Je remplis le champ "password"    ${my_user}
    Cliquer sur le bouton de "submit"

Cliquer sur le bouton d'inscription
    [Documentation]     L'utilisateur clique sur le bouton de connexion

    web.Cliquer Sur Element Visible    xpath=//*[@id="signup"]

Cliquer sur le bouton de "submit"
    [Documentation]     L'utilisateur clique sur le bouton de submit

    web.Cliquer Sur Element Visible    xpath=//*[@id="submit"]
    Log    Le bouton de submit est bien cliqué
    Log    Le bouton de connexion est bien cliqué

Je suis sur la page de connexion
    [Documentation]     L'utilisatuer est sur la page de connexion

    web.Le Texte De L'Element Doit Avoir La Valeur Attendue    xpath=html/body/h1    Contact List App
    Log    La page de connexion est bien Visible

Je ne suis plus sur la page de connexion
    [Documentation]     L'utilisatuer n'est plus sur la page de connexion

    web.La Page Ne Contient Pas L'Element    xpath=//*[@id="signup"]
    Log    La page de connexion n'est plus Visible

Je remplis le champ "email"
    [Documentation]     L'utilisateur remplis le champ email avec son email
    [Arguments]     ${my_user}

    web.Saisir Dans Element Actif    xpath=//*[@id="email"]    ${my_user}[email]
    Log    Le champ email est bien rempli avec l'email de l'utilisateur

Je remplis le champ "password"
    [Documentation]     L'utilisateur remplis le champ password avec son password
    [Arguments]     ${my_user}
    
    web.Saisir Dans Element Actif    xpath=//*[@id="password"]    ${my_user}[password]
    Log    Le champ password est bien rempli avec le password de l'utilisateur