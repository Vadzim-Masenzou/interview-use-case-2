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

# Following link on Google Drive contains 2 video files:
https://drive.google.com/drive/folders/1YwKCs9oNTDGz88mYsfO3Iuqy4mcM8Jdx?usp=sharing
1. 'configuration_guide' video file which demonstrates how to configure the project
2. 'acceptance_criteria_guide' video file which demonstrates ACs
    
PS: Project has data folder which contains 'products_list_test.csv' file with dummy products data (if needed)
