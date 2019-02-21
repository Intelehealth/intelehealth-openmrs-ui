intelehealthAdditionalDocs.factory('intelehealthAdditionalDocsFactory', [ '$http', '$q',
		function($http, $q) {
			return {
				fetchAdditionalDocuments : function(patientUuid, visitId) {
					var url = "http://13.232.112.226:1337/parse/classes/AdditionalDocuments?where={\"PatientID\":\"" + patientUuid +"\",\"VisitID\":\"" + visitId + "\"}";
					var headers = {headers:  {
				        'X-Parse-Application-Id': 'app2',
				        'X-Parse-REST-API-Key': 'undefined'
							}
						};
					return $http.get(url, headers);
				}
			};

		} ]);
