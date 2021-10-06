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
