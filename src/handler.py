import json, boto3, os, uuid

def handler(event, context):
    print(f"tjs===== event is : {event} ")
    
    table = boto3.resource('dynamodb').Table(os.environ['TABLE_NAME'])
    method = event.get('requestContext', {}).get('http', {}).get('method', 'GET')

    if method == 'POST' or 'message' in event:
        data = json.loads(event.get('body', '{}')) if method == 'POST' else event
        item = {'id': str(uuid.uuid4()), **data}
        table.put_item(Item=item)

        return {
            'statusCode': 200, 
            'body': json.dumps(item)
        }
    
    result = table.scan()
    return {
        'statusCode': 200,
        'body': json.dumps(result['Items'])
    }