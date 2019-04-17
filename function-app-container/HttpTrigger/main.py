import logging
import azure.functions as func
import subprocess

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    subscription_id = req.params.get('subscription_id')
    tenant = req.params.get('tenant')
    secret = req.params.get('secret')
    client = req.params.get('client_id')

    body = req.get_body()

    f = open("./playbook.yml", "wb")
    f.write(body) 
    f.close()

    cmd = "ansible-playbook ./playbook.yml"
    process = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output, error = process.communicate()

    return func.HttpResponse(str(output) + str(error), headers={"Access-Control-Allow-Origin": "*"})
