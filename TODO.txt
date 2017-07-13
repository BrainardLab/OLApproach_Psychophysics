Jack/Michael
    A) Add OL to the names of routines copied over from +Psychophysics.
        Need to change call, and header comments to match.
    I deleted the +Psychophysics versions already.
    
    B) I think that files that get written into data do not use cache files. These
    get run per session and we have a scheme that keeps them apart.
    
    C) Certain routines are not respecting our preferences.  For example,
    OLReceptorIsolateMakeModulationStartsStops is ignoring the detailed pref.
        a) Probably don't want to pass file suffix either, since we can construct it
        there.
        
        
        
    

    