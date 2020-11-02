#!/bin/bash
end_point=$1
echo "application end_point = $end_point"
 
while true; do date && curl "http://$end_point"; sleep 1; done
