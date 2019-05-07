function nominalContrasts = nominalReceptorContrastDirections(a,b, receptors)

SPDs = [a.ToPredictedSPD b.ToPredictedSPD];
SPDs = SPDs + a.calibration.computed.pr650MeanDark;

nominalContrasts = SPDToReceptorContrast(SPDs,receptors);