<div class="info-section">
    <div class="info-header">
        <i class="icon-calendar"></i>
        <h3>RECENT VISITS</h3>
    </div>
    <div class="info-body" ng-controller="recentVisitController">
	        <div ng-repeat="visit in recentVisits" class="clear"> 
		      <a href='/openmrs/intelehealth/overview/patientSummaryVso.page?patientId={{patientId}}&visitId={{visit.uuid}}' class="visit-link">{{visit.display | visitdate | date: 'dd.MMM.yyyy'}}</a>
              <span><b>{{visit.observation}}</b></span>
              <div class="tag" ng-if="visit.visitStatus">{{visit.visitStatus}}</div>   
	       </div>

           <br>
    </div>
</div>

