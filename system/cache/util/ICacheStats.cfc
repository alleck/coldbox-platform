<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The main interface for a CacheBox cache provider statistics object

----------------------------------------------------------------------->
<cfinterface hint="The main interface for a CacheBox cache provider statistics object">

	<!--- Constructor --->
	<cffunction name="init" access="public" output="false" returntype="any" hint="Constructor">
		<cfargument name="cacheProvider" type="coldbox.system.cache.ICacheProvider" required="true" hint="The associated cache manager/provider"/>
	</cffunction>
	
	<!--- Get Associated Cache --->
	<cffunction name="getAssociatedCache" access="public" output="false" returntype="coldbox.system.cache.ICacheProvider" hint="Get the associated cache provider/manager">
	</cffunction>
	
	<!--- Get Cache Performance --->
	<cffunction name="getCachePerformanceRatio" access="public" output="false" returntype="numeric" hint="Get the cache's performance ratio">
	</cffunction>
	
	<!--- Get Cache object count --->
	<cffunction name="getObjectCount" access="public" output="false" returntype="numeric" hint="Get the cache's object count">
	</cffunction>
	
	<!--- clearStats --->
	<cffunction name="clearStats" output="false" access="public" returntype="void" hint="Clear the stats">
	</cffunction>	
		
	<!--- Get/Set Garbage Collections --->
	<cffunction name="getGarbageCollections" access="public" output="false" returntype="numeric" hint="Get Garbage Collections">
	</cffunction>
	
	<!--- Eviction Count --->
	<cffunction name="getEvictionCount" access="public" returntype="numeric" output="false" hint="Get the eviction count">
	</cffunction>
	
	<!--- The hits --->
	<cffunction name="getHits" access="public" returntype="numeric" output="false" hint="Get the hits">
	</cffunction>
	
	<!--- The Misses --->
	<cffunction name="getMisses" access="public" returntype="numeric" output="false" hint="Get the misses">
	</cffunction>
	
	<!--- Last Reap Date Time --->
	<cffunction name="getLastReapDatetime" access="public" returntype="string" output="false" hint="Get the last reap date time property">
	</cffunction>

</cfinterface>