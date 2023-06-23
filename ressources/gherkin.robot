*** Settings ***
Resource          ../services/parcours.robot

Library           FakerLibrary    locale=en_US

*** Keywords ***
un utilisateur inconnu veut s'inscrire en arrivant sur le site
    [Documentation]    Un utilisateur souhaite s'inscrire sur le site
    [Tags]    TNR INS
    [Arguments]    ${THE_DATA}

    Set Suite Variable    ${THE_DATA}
    Log To Console    ${THE_DATA}
    parcours.Aller sur la page d'inscription

l'utilisateur remplit le formulaire d'inscription
    [Documentation]    L'utilisateur souhaite remplir le formulaire d'inscription
    [Tags]   TNR INS
    
    ${THE_DATA}[firstname]=    FakerLibrary.First Name Male
    ${THE_DATA}[lastname]=    FakerLibrary.Last Name Male
    ${THE_DATA}[email]=    FakerLibrary.Email
    ${THE_DATA}[password]=    FakerLibrary.Password
    
    Log To Console    ${THE_DATA}
    parcours.Remplir le formulaire d'inscription    ${THE_DATA}

il doit être inscrit sur le site
    [Documentation]    L'utilisateur doit être inscrit
    [Tags]    TNR INS
    parcours.Être inscrit sur le site

un utilisateur connecté
    [Documentation]    L'utilisateur est connecté
    [Tags]    TNR AUTH
    [Arguments]    ${THE_DATA}

    Set Suite Variable    ${THE_DATA}
    parcours.Connexion sur le site    ${THE_DATA}

L'utilisateur ajoute un nouveau contact
    [Documentation]    L'utilisateur ajoute un nouveau contact
    [Tags]    TNR AUTH

    parcours.Ajouter un nouveau contact    ${THE_DATA}

le contact doit être créé
    [Documentation]    Le contact doit être ajouté
    [Tags]    TNR AUTH

    parcours.Ajout du nouveau contact avec succès