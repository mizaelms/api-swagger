#!/bin/bash
	rm -rf api
  	mkdir api
	cd api
	mkdir api-doc
	rm index.html

	echo "<!DOCTYPE html><html><head><meta charset='UTF-8'><title>APIs GNP</title><link rel='stylesheet' type='text/css' href='https://cdn.datatables.net/v/dt/dt-1.10.18/datatables.min.css'/><link rel='stylesheet' type='text/css' href='https://www.gstatic.com/recaptcha/releases/Zy-zVXWdnDW6AUZkKlojAKGe/styles__ltr.css'/><link rel='stylesheet' type='text/css' href='css/style.css'/><script type='text/javascript' src='https://code.jquery.com/jquery-3.3.1.js'></script><script type='text/javascript' src='https://cdn.datatables.net/1.10.19/js/jquery.dataTables.min.js'></script><script type='text/javascript' src='js/index.js'></script> <link rel='shortcut icon' href='https://storage.googleapis.com/static-portalcorporativo.gnp.com.mx/favicon.ico'> <link rel='icon' type='image/png' sizes='96x96' href='https://storage.googleapis.com/static-portalcorporativo.gnp.com.mx/images/favicon.png'> <!-- Styles --> <link href='https://fonts.googleapis.com/icon?family=Material+Icons' rel='stylesheet'> <link href='https://fonts.googleapis.com/css?family=Open+Sans:400,600' rel='stylesheet'> <link href='https://fonts.googleapis.com/css?family=Lato:100' rel='stylesheet'></head><body>" >> index.html
	
	echo "<div class='nav-header'><div class='container'><nav class='row' id='main-nav'><!-- Desktop Zone --><div class='col xl2 l2 m6 s6 gnp-logo logos'><a href='/'><img class='fr-fic fr-dii' alt='logo-gnp' src='https://static-portalcorporativo-uat.gnp.com.mx/images/site/GNP%20CANCER.png' style='width: 125px; height: 40px;'></a></div><div class='col xl2 push-xl8 l2 push-l8 m6 s6 right-align logos'><img class='fr-fic fr-dii' alt='slogan' src='https://static-portalcorporativo.gnp.com.mx/images/site/logo_vivir_increible.svg'></div><div class='neoHeader'><ul><li id='Personas' class='active'><a href='index.html' >Openshift</a></li><li id='Empresas'><a href='cloud.html'>Cloud</a></li></ul></div></nav></div></div>" >> index.html

	#echo "<!DOCTYPE html>" >> index.html
	#echo "<html>" >> index.html
	#echo "<head><meta charset='UTF-8'><title>APIs GNP</title>" >> index.html
	#echo "<link rel='stylesheet' type='text/css' href='https://cdn.datatables.net/v/dt/dt-1.10.18/datatables.min.css'/>" >> index.html
        #echo "<script type='text/javascript' src='https://code.jquery.com/jquery-3.3.1.js'></script>" >> index.html
	#echo "<script type='text/javascript' src='https://cdn.datatables.net/1.10.19/js/jquery.dataTables.min.js'></script>" >> index.html
	#echo "<script type='text/javascript' src='js/index.js'></script>" >> index.html
	echo "<table id='api-swagger' class='display' style='width:100%'><thead><tr>" >> index.html
	echo "<th>Proyecto</th><th>Microservicio</th><th>Editor</th><th>Descripci&oacute;n</th></tr></thead><tbody>" >> index.html
	for PRO in $( oc get projects -o name);
        do
                PA=$(echo $PRO | sed 's/project.project.openshift.io\///'); oc project $PA;
                if [[ ${PA} != *"logging"* ]];then
		    if [[ ${PA} != *"openshift"* ]];then
                        for i in $( oc get pods -o name);
                        do
                                P=$(echo $i | sed 's/pod\///') ;
                                echo "POD: $P"
				URL ="N/D"
				LS=$(oc exec $P curl 127.0.0.1:8080/swagger-ui.html);
				if [[ ${LS} = *"<title>Swagger UI</title>"* ]];then
					echo "Desubriendo swagger "
					echo "oc exec $P curl 127.0.0.1:8080/v2/api-docs -n $PA"
					JSON=$(oc exec $P curl 127.0.0.1:8080/v2/api-docs)
					#echo "------------------------------------------------------------"
					URL="$P.oscp.gnp.com.mx/swagger-ui.html";
				URL="http://swagger-editor-matriz-pruebas-qa.oscp.gnp.com.mx/?url=$P.json"
				echo $URL
				#echo $JSON
				DESC=$(echo $JSON | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w description | head -n 1)
				TAGS=$(echo $JSON | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w operationId)
				SUMMARY=$(echo $JSON | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w summary)
				echo $DESC
				echo "$JSON" >> $P.json
				sed -i '' 's/,"GNP":"Grupo Nacional Provincial"//g' *.json
				ruby -ryaml -rjson -e 'puts YAML.dump(JSON.parse(STDIN.read))' < $P.json > $P.yaml
				LINK=$(curl -X POST "https://generator.swagger.io/api/gen/clients/html2" -H "accept: application/json" -H "Content-Type: application/json" -d "{ \"spec\": $JSON, \"options\": { \"additionalProp1\": \"string\", \"additionalProp2\": \"string\", \"additionalProp3\": \"string\" }, \"swaggerUrl\": \"$URL\", \"authorizationValue\": { \"value\": \"string\", \"type\": \"string\", \"keyName\": \"string\" }, \"securityDefinition\": { \"type\": \"string\", \"description\": \"string\" }}" | sed -n 's|.*"link":"\([^"]*\)".*|\1|p')
				
				if [[ ${LINK} = *"http"* ]];then
					echo "LINK: $LINK"
					echo "<tr><td>$PA</td><td><a href='api-doc/$P/index.html' target='_blank'>$P</a></td><td><a href='http://swagger-editor-api-documentation-dev.oscp.gnp.com.mx/?url=$P.yaml' target='_blank'>$P.json</a></td><td>$DESC<div id='tags' style='display:none'>$TAGS $SUMMARY</div></td></tr>" >> index.html
					curl -o $P.zip $LINK
					unzip $P.zip
					mv html2-client api-doc/$P
					rm $P.zip
				else
					echo "<tr><td>$PA</td><td><a href='#'>$P</a></td><td>N/D</td><td>No se encontro especificaci&oacute;n swagger</td></tr>" >> index.html
				fi;				
				fi;
                                echo "$PA $P $URL" >> swagger.txt;
                        done;
		  fi;
                fi;
         done;
	echo " </tbody></table></body></html>" >> index.html
	mkdir yaml
	mkdir json
	mv *.json json/
	mv *.yaml yaml/
	oc project api-documentation-dev
	POD=pod/$(oc get pods | grep Running | grep 'swagger-editor' | awk '{print $1}')
	POD=$(echo $POD | sed 's/pod\///') ;
	oc rsync yaml/ $POD:/usr/share/nginx/html/
	sed -i '' 's/info|description|//g' index.html
        cp index.html /Users/mizael/Documents/workspace-spring-tool-suite-4-4.3.2.RELEASE/api-swagger/
	cp -r api-doc/* /Users/mizael/Documents/workspace-spring-tool-suite-4-4.3.2.RELEASE/api-swagger/api-doc/
	cd /Users/mizael/Documents/workspace-spring-tool-suite-4-4.3.2.RELEASE/api-swagger/
	git add .
	git commit -m "update info" 
	git push origin master 
	echo "Ejecutando actulizacion de pod"
	sleep 60
	oc start-build swagger	
	cd ..
