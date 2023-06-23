*** Settings ***
Resource          ./ressource/pageConnexion.robot
Resource          ./ressource/pageFormulaire_Inscription.robot
Resource          ./ressource/pageContact.robot

*** Keywords ***
Aller sur la page d'inscription
    [Documentation]    parcours d'inscription d'un nouvel utilisateur

    pageConnexion.Je suis sur la page de connexion
    pageConnexion.Cliquer sur le bouton d'inscription
    pageFormulaire_Inscription.Je suis sur la page du formulaire

Remplir le formulaire d'inscription
    [Documentation]    remplissage du formulaire d'inscription
    [Arguments]    ${my_user}

    pageFormulaire_Inscription.Renseignement des informations personnelles dans le formulaire    ${my_user}

Être inscrit sur le site
    [Documentation]    Confirmation de l'inscription

    pageContact.Je suis sur la page de contact

Connexion sur le site
    [Documentation]    Connexion d'un utilisateur
    [Arguments]    ${my_user}

    pageConnexion.Je suis sur la page de connexion
    pageConnexion.Authentification    ${my_user}
    pageConnexion.Je ne suis plus sur la page de connexion