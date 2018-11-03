<div class="info-section">
    <div class="info-header">
        <i class="icon-calendar"></i>
        <h3>RECENT VISITS</h3>
    </div>
    <div class="info-body" ng-controller="recentVisitController">
	       <div ng-repeat="visit in recentVisits" class="clear">
		       	<a href='/openmrs/intelehealth/overview/patientSummary.page?patientId={{patientId}}&visitId={{visit.uuid}}' class="visit-link">{{visit.display | visitdate | date: 'dd.MMM.yyyy'}}</a>
		       	<div ng-repeat="obs in visit.obser"><div ng-repeat="ob in obs">{{ob}}</div></div>
                   
                <div class="tag" ng-if="visit.visitStatus">{{visit.visitStatus}}</div>  
	       </div>
    </div>
    
</div>

