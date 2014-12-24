xInforMonitor (  )
{

        cat list_matchmatss | tail -4 >temp1
	cat temp1 fwhm_lastdata | tr '\n' ' ' >listForMonitor 
}

