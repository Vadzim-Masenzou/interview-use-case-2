# Steps to configure the project

- Clone git repository to your local machine
- Create scratch org using command below:
    ```
    sfdx force:org:create -f project-scratch-def.json -a <your scratch org name> --setdefaultusername
    ```
- Go to cloned repo directory and push the code to your scratch org using command below:
    ```
    sfdx force:source:push
    ```
- After successfull deploy go to Setup -> Lightning App Builder and set 'Order Record Page' Lightning Page as Org Default
