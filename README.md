# Steps to configure the project

1. Clone git repository to your local machine
2. Go to cloned repo directory and create scratch org using command below:
    ```
    sfdx force:org:create -f config/project-scratch-def.json -a <your scratch org name> --setdefaultusername
    ```
3. Push the code to your scratch org using command below:
    ```
    sfdx force:source:push
    ```
4. After successfull deploy go to Setup -> Lightning App Builder and set 'Order Record Page' Lightning Page as Org Default
5. Go to Order detail page and find components there :)


# Project has data folder which contains following files
1. 'products_list_test.csv' file with dummy products data (if needed)
2. 'configuration_guide' video file which demonstrates how to configure the project
3. 'acceptance_criteria_guide' video file which demonstrates ACs
    
