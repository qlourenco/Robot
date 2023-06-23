*** Settings ***
Documentation     Keywords de la page de contact

Resource    ../../socle/ressources/utils.robot
Resource    ../../socle/ressources/web.robot

*** Keywords ***
Je suis sur la page de contact
    [Documentation]     Je suis sur la page contact
    web.La Page Contient L'Element Visible    //*[@id="logout"]