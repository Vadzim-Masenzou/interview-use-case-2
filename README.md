# Steps to configure the project

1. Clone git repository to your local machine
2. Create scratch org using command below:
    ```
    sfdx force:org:create -f project-scratch-def.json -a <your scratch org name> --setdefaultusername
    ```
3. Go to cloned repo directory and push the code to your scratch org using command below:
    ```
    sfdx force:source:push
    ```
4. After successfull deploy go to Setup -> Lightning App Builder and set 'Order Record Page' Lightning Page as Org Default
5. Go to Order detail page and find components there :)
