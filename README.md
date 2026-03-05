# cadenceVivaToTikz
Virtuoso simulation suite from Cadence Design Systems is used extensively for analog circuit design. The quality of
the plots from Virtuoso Visualization and Analysis (ViVa), the built-in visualization tool is not of sufficient quality
for publishing. This skill script converts the selected waveforms in a given subWindow of ViVa to a TikZ picture or
a pdf file for inclusion in LaTeX documents. TikZ picture can be generated solely using skill. Generating a pdf file
requires a local LaTeX installation.

The pdf file has complete documentation.

Load the skill file using the following in the CIW. You have to specify the complete path if the skill file is in a
different folder than where you executed “virtuoso”.

load(“nkWaveToTikz.il”)

Select the waveforms and run the following in the CIW. All arguments are optional. Arguments can be in any order,
but must be in the keyword form, i.e. the keyword ?keyName followed by the argument keyName.

nkWaveToTikz(
?fileName fileName
?plotMode plotMode
?width width
?relheight relheight
?traceWidth traceWidth
?precision precision
?xLimits xLimits
?yLimits yLimits
?xLabels xLabels
?yLabels yLabels
?xTickLabels xTickLabels
?yTickLabels yTickLabels
?xTicks xTicks
?yTicks yTicks
?colors colors
?legends legends
?xModes xModes
?yModes yModes
?textLabels textLabels
?minorGrid minorGrid
?markers markers
?waveAssign waveAssign
?undersample undersample
?stripVsep stripVsep
?noAxes noAxes
?genPdf genPdf
?retainTexFile retainTexFile
?headerFilePath headerFilePath
?additionalAxisArgs additionalAxisArgs
)
