*** Settings ***
Documentation       Template robot main suite.
Library    RPA.Browser.Selenium    auto_close=${FALSE}
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.FileSystem
Library    RPA.Archive
Library    RPA.Robocorp.Vault

*** Variables ***
${webURL}=    https://robotsparebinindustries.com/#/robot-order
${input_ExcelFile}=    https://robotsparebinindustries.com/orders.csv
${Receipt_Path}=    ${OUTPUT_DIR}${/}receipt

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    #Open the robot order website
    #${orders}=    Get orders
    #FOR    ${row}    IN    @{orders}
    #    Close the annoying modal
    #    Fill the form    ${row}
    #    Preview the robot
    #    #Sleep    10s
    #    Submit the order
    #    ${pdf}=    Store the receipt as a PDF file    ${row}
    #    ${screenshot}=    Take a screenshot of the robot    ${row}
    #    Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
    #    Go to order another robot
    #END
    Create a ZIP file of the receipts
    #[Teardown]    Close Browser

*** Keywords ***
Open the robot order website
    #Open Available Browser    https://robotsparebinindustries.com/#/robot-order    maximized=true
    Open Available Browser    ${webURL}    maximized=true

Get orders
    #Download    https://robotsparebinindustries.com/orders.csv    overwrite=true
    Download    ${input_ExcelFile}    overwrite=true
    ${table}=    Read table from CSV    orders.csv
    RETURN    ${table}
    
Close the annoying modal
    Click Element If Visible    class:btn-dark

Fill the form
    [Arguments]    ${row}
    Select From List By Value    name:head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]    # name=body is the group_name
    Input Text   xpath://form//Input[@type='number']    ${row}[Legs]
    Input Text    id:address    ${row}[Head]

Preview the robot
    Click Button    id:preview

Submit the order
    Click Button    id:order
    &{dictionary_ElementPresence_alert}    Get Element Status    class:alert-danger
    Log    ${dictionary_ElementPresence_alert}[visible]
    #IF    ${dictionary_ElementPresence.visible} == True
    #    Click Button    id:order
    #END
    WHILE    ${dictionary_ElementPresence_alert.visible}
        &{dictionary_ElementPresence_Receipt}    Get Element Status    id:receipt
        IF    ${dictionary_ElementPresence_Receipt.visible} == True
            log     Order Success!!! and moving forward.
            BREAK
        ELSE
            Click Button    id:order
            Sleep    2s
        END
    END
    

Store the receipt as a PDF file
    [Arguments]    ${row}
    Wait Until Element Is Visible    id:receipt
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    #${Receipt_Path}=    ${OUTPUT_DIR}${/}receipt${/}${row}[Order number].pdf    #path of the pdf saved
    #log ${Receipt_Path}
    Html To Pdf    ${receipt_html}    ${Receipt_Path}${/}${row}[Order number].pdf    overwrite=true    #HTML content saving to pdf
    RETURN     ${Receipt_Path}${/}${row}[Order number].pdf


Take a screenshot of the robot
    [Arguments]    ${row}
    Wait Until Element Is Visible    id:robot-preview-image
    Screenshot    id:robot-preview-image    ${Receipt_Path}${/}${row}[Order number].png    #saving to preview image
    RETURN     ${Receipt_Path}${/}${row}[Order number].png


Go to order another robot
    Click Button    id:order-another


Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    #Open Pdf    ${pdf}
    ${List_of_Files}=    Create List    ${pdf}    ${screenshot}:align=center
    Add Files To Pdf    ${List_of_Files}    ${pdf}
    #Close Pdf    ${pdf}
    
Create a ZIP file of the receipts
    #Archive Folder With Zip    ${OUTPUT_DIR}${/}receipt${/}    ${OUTPUT_DIR}${/}receipt${/}archive_Pdf.Zip    include=*.pdf
    Archive Folder With Zip    ${Receipt_Path}    ${Receipt_Path}${/}archive_Pdf.Zip    include=*.pdf
    #--------------
    #${test-1}=    Set Variable    ${OUTPUT_DIR}${/}receipt${/}archive_Pdf.Zip
    #Archive Folder With Zip    ${Receipt_Path}    ${test-1}    include=*.pdf
    #-------------




