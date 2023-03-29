#!/usr/bin/bash
#

langs=(en fr it ja ko zh-cn)
#langs=(en)

DATA_DIR=data_staging

SCHEMA=http
ELASTIC_USER=elastic
ELASTIC_PORT=9200
PREFIX=

# Dev
# ELASTIC_PWD=5RW97bd9yqE1P5x3uUJT2v24
# Staging
#ELASTIC_PWD=5Ox3512S4LDPB3i0KFr9gpG9
# Prod
#ELASTIC_PWD=N62zh2Rqs91B19wdGve7F9Q6

TOKEN=`echo -n "elastic:$ELASTIC_PWD" | base64`

# Common indexes
NODE_TLS_REJECT_UNAUTHORIZED=0 elasticdump --input="$DATA_DIR/availability.json" --output="$SCHEMA://$ELASTIC_USER:$ELASTIC_PWD@localhost:$ELASTIC_PORT/${PREFIX}availability"
NODE_TLS_REJECT_UNAUTHORIZED=0 elasticdump --input="$DATA_DIR/sort_option.json" --output="$SCHEMA://$ELASTIC_USER:$ELASTIC_PWD@localhost:$ELASTIC_PORT/${PREFIX}sort_option"
NODE_TLS_REJECT_UNAUTHORIZED=0 elasticdump --input="$DATA_DIR/price_ranges.json" --output="$SCHEMA://$ELASTIC_USER:$ELASTIC_PWD@localhost:$ELASTIC_PORT/${PREFIX}price_ranges"
NODE_TLS_REJECT_UNAUTHORIZED=0 elasticdump --input="$DATA_DIR/attributes.json" --output="$SCHEMA://$ELASTIC_USER:$ELASTIC_PWD@localhost:$ELASTIC_PORT/${PREFIX}attributes"
NODE_TLS_REJECT_UNAUTHORIZED=0 elasticdump --input="$DATA_DIR/category_attribute.json" --output="$SCHEMA://$ELASTIC_USER:$ELASTIC_PWD@localhost:$ELASTIC_PORT/${PREFIX}category_attribute"
NODE_TLS_REJECT_UNAUTHORIZED=0 elasticdump --input="$DATA_DIR/category_en.json" --output="$SCHEMA://$ELASTIC_USER:$ELASTIC_PWD@localhost:$ELASTIC_PORT/${PREFIX}category_en"
NODE_TLS_REJECT_UNAUTHORIZED=0 elasticdump --input="$DATA_DIR/stores.json" --output="$SCHEMA://$ELASTIC_USER:$ELASTIC_PWD@localhost:$ELASTIC_PORT/${PREFIX}stores"
NODE_TLS_REJECT_UNAUTHORIZED=0 elasticdump --input="$DATA_DIR/product_en.json" --output="$SCHEMA://$ELASTIC_USER:$ELASTIC_PWD@localhost:$ELASTIC_PORT/${PREFIX}product_en"

exit 1

# Per lang indexes
for i in "$langs[@]"
do
    :
        NODE_TLS_REJECT_UNAUTHORIZED=0 elasticdump --input="$DATA_DIR/category_$i.json" --output="$SCHEMA://$ELASTIC_USER:$ELASTIC_PWD@localhost:$ELASTIC_PORT/${PREFIX}category_$i"

        curl -k --location --request PUT "$SCHEMA://$ELASTIC_USER:$ELASTIC_PWD@localhost:$ELASTIC_PORT/${PREFIX}product_$i" \
            --header "Authorization: Basic $TOKEN" \
            --header 'Content-Type: application/json' \
            --data '{
                "mappings": {
                    "properties": {
                        "price": {
                            "type": "nested"
                        }
                    }
                }
            }'
        NODE_TLS_REJECT_UNAUTHORIZED=0 elasticdump --input="$DATA_DIR/product_$i.json" --output="$SCHEMA://$ELASTIC_USER:$ELASTIC_PWD@localhost:$ELASTIC_PORT/${PREFIX}product_$i"
done

echo "End."