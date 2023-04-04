*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library    RPA.Browser.Selenium    auto_close=${FALSE}
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.Desktop
Library           RPA.PDF
Library    RPA.Archive
Library    OperatingSystem
Library    zipfile
*** Tasks ***
Orders robots from RobotSpareBin Industries Inc.
    Open the robot order website
    Download documents cvs
    Fill in the order form through the csv file
    Create zip of pdfs

*** Keywords ***
Open the robot order website
    Open Available Browser        https://robotsparebinindustries.com/#/robot-order
    Click Button   OK
Download documents cvs
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True;
Fill in the order form through the csv file
    ${orders}=  Read table from CSV  orders.csv  header=True
    Create Directory    ${OUTPUT_DIR}/resul
    FOR    ${order}    IN    @{orders}
        ${pngName} =   Catenate	SEPARATOR=    order-Pdf-    ${order}[Order number]    .pdf
        Fill and submit the form for one order    ${order}
        ${passed}    Run Keyword And Return Status    Element Should Be Visible    id:receipt
        IF    ${passed} == True
        ${sales_results_html}=    Get Element Attribute    id:receipt    outerHTML
        Html To Pdf    ${sales_results_html}    ${OUTPUT_DIR}/resul${/}${pngName}
        Click Element    id:order-another
        Click Button   OK
        ELSE
        Log    message
    END
    END
Fill and submit the form for one order
    [Arguments]    ${order}
    ${idBody} =   Catenate	SEPARATOR=    id-body-    ${order}[Body]
    Log    ${idBody}
    Select From List By Value    id:head    ${order}[Head]
    Click Element    id:${idBody}
    Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${order}[Legs]
    Input Text    id:address    ${order}[Address]
    Click Element    id:order
Create zip of pdfs
    ${orders}=  Read table from CSV  orders.csv  header=True
    Archive Folder With Zip    ${OUTPUT_DIR}/resul${/}    ${OUTPUT_DIR}${/}/resultado.zip