/************************************************************************/
/* nkWaveToTikz.il

Author Nagendra Krishnapura
Dept. of Electrical Engineering, Indian Institute of Technology Madras, Chennai 600036, India.
Language SKILL
Date: 19 January 2026
Modified
By

Get a Tikz picture of selected waveforms from a Cadence ViVa plot
*************************************************************************/

procedure( nkWaveToTikz(\@key
    fileName 
    (plotMode "single") 
    (width "\\textwidth") 
    (relheight 1.0)
    (traceWidth "thick")
    precision
    xLimits
    yLimits
    xLabels
    yLabels
    xTickLabels
    yTickLabels
    xTicks
    yTicks
    colors
    legends
    xModes
    yModes
    textLabels
    minorGrid 
    (markers 0)
    waveAssign
    (undersample 1)
    stripVsep 
    (noAxes 0)
    genPdf
    retainTexFile
    (headerFilePath ".")
    additionalAxisArgs
) ; input arguments

    let( (addPlotLine0 addPlotLine axisFinishLine colonDef color fileName0 fileNameBase fileNameWordList labelcolor legendText lenData nstrips nstripwaves nwaves picFinishLine picStartLine stripheight subwin targetFile texFileName waveAssign0 wave waves win xlabel xlimit xmode xtick xticklabel xyData ylabel ylimit ymode ytick yticklabel labelx labely labeltext
    )
	if( !fileName
	    then
	    (fileNameWordList = parseString(getCurrentTime()))
	    (fileNameBase = nth(0 fileNameWordList))
	    for( kk 1 3
		(fileNameBase = sprintf(nil "%s%s" fileNameBase 
			nth(kk fileNameWordList)
		    ))
	    )
	    colonDef = pcreCompile("[:]")
	    fileNameBase = pcreReplace(colonDef fileNameBase "" 0)
	    (fileName0 = sprintf(nil "%s%s" fileNameBase ".tikz"))
	    else 
	    fileName0 = fileName
	    fileNameBase = nth(0 parseString(fileName "."))
	) ; if(!fileName
	printf("%s%s\n" "file name base" fileNameBase)
	; Get the current subwindow and selected waves
	(win = awvGetCurrentWindow()) ; Current window id
	(subwin = awvGetCurrentSubwindow(win)) ; Current subwindow id
	(waves = awvGetSelectedTraceWaveforms(win ?subwindow subwin))
	(nwaves = length(waves)) 
	printf("%s%d\n" "Number of waveforms: " nwaves) 
	if( waveAssign
	    then
	    (waveAssign0 = waveAssign)
	    (nstrips = length(waveAssign0))
	    else
	    (waveAssign0 = nil)
	    case( plotMode
		("row"
		    (nstrips = nwaves)
		    for( kk 0 (nwaves - 1)
			(waveAssign0 = cons(cons((nwaves - kk) nil) waveAssign0))
		    ))
		("column"
		    (nstrips = nwaves)
		    for( kk 0 (nwaves - 1)
			(waveAssign0 = cons(cons((nwaves - kk) nil) waveAssign0))
		    ))
		(t
		    (nstrips = 1)
		    for( kk 0 (nwaves - 1)
			(waveAssign0 = cons((nwaves - kk) waveAssign0))
		    )
		    (waveAssign0 = cons(waveAssign0 nil)))
	    ) ; case plotMode
	) ; if waveAssign
	printf("%s%d\n" "Number of strips: " nstrips) 
	case( plotMode
	    ("row" ; Not working correctly-same as column
		(stripheight = (relheight / nstrips))
		(picStartLine = "\\begin{tikzpicture}\n\\matrix{")
		(picFinishLine = "};\n\\end{tikzpicture}")
		(axisFinishLine = "\\end{axis} \\\\"))
	    ("column"
		(stripheight = (relheight / nstrips))
		(picStartLine = "\\begin{tikzpicture}\n\\matrix{")
		(picFinishLine = "};\n\\end{tikzpicture}")
		(axisFinishLine = "\\end{axis} \\\\"))
	    (t ; Default
		(nstrips = 1)
		(stripheight = relheight)
		(picStartLine = "\\begin{tikzpicture}")
		(picFinishLine = "\\end{tikzpicture}")
		(axisFinishLine = "\\end{axis}"))
	) ; case plotMode

	; Check if the number of list entries is less than the number of strips
	; If not, repeat the last one to the remaining ones
	; To have the same for all strips the list needs to have only one item
	if( xLimits
	    then
	    (xLimits = assignStripVars(xLimits nstrips))
	) 
	if( yLimits
	    then
	    (yLimits = assignStripVars(yLimits nstrips))
	) 
	if( xTickLabels
	    then
	    (xTickLabels = assignStripVars(xTickLabels nstrips))
	) 
	if( yTickLabels
	    then
	    (yTickLabels = assignStripVars(yTickLabels nstrips))
	) 
	if( xTicks
	    then
	    (xTicks = assignStripVars(xTicks nstrips))
	)
	if( yTicks
	    then
	    (yTicks = assignStripVars(yTicks nstrips))
	) 
	if( xModes
	    then
	    (xModes = assignStripVars(xModes nstrips))
	) 
	if( yModes
	    then
	    (yModes = assignStripVars(yModes nstrips))
	) 
	if( xLabels
	    then
	    (xLabels = assignStripVars(xLabels nstrips))
	) 
	if( yLabels
	    then
	    (yLabels = assignStripVars(yLabels nstrips))
	)
	if( minorGrid
	    then
	    (minorGrid = assignStripVars(minorGrid nstrips))
	) 
	if( minorGrid
	    then
	    (minorGrid = assignStripVars(minorGrid nstrips))
	)
	if( colors
	    then
	    (colors = assignWaveColors(colors nwaves))
	)
	case( markers
	    (0
		(addPlotLine0 = sprintf(nil "%s%s%s" " +[" traceWidth ",mark=none")))
	    (1
		(addPlotLine0 = sprintf(nil "%s%s%s" " +[" traceWidth "")))
	    (t
		(addPlotLine0 = sprintf(nil "%s%s%s%L%s" " +[" traceWidth ",mark repeat={"
			markers "}"
		    )))
	) ; case( markers
	
	; Start writing into the output file
	(targetFile = outfile(fileName0 "w")) 
	fprintf(targetFile "%s\n" picStartLine)
	; loop through strips
	for( strip 0 (nstrips - 1)
	; Initialize
	    (legendText = nil)
	    ; Find out which options are set
	    if( xModes
		then
		(xmode = nth(strip xModes))
		else
		(xmode = nil)
	    )
	    if( yModes
		then
		(ymode = nth(strip yModes))
		else
		(ymode = nil)
	    )
	    if( xLabels
		then
		(xlabel = nth(strip xLabels))
		else
		(xlabel = nil)
	    )
	    if( yLabels
		then
		(ylabel = nth(strip yLabels))
		else
		(ylabel = nil)
	    )
	    if( xLimits
		then
		(xlimit = nth(strip xLimits))
		else
		(xlimit = nil)
	    )
	    if( yLimits
		then
		(ylimit = nth(strip yLimits))
		else
		(ylimit = nil)
	    )
	    if( (xTickLabels && (length(xTickLabels) == nstrips))
		then
		(xticklabel = nth(strip xTickLabels))
		else
		(xticklabel = nil)
	    )
	    if( (yTickLabels && (length(yTickLabels) == nstrips))
		then
		(yticklabel = nth(strip yTickLabels))
		else
		(yticklabel = nil)
	    )
	    if( (xTicks && (length(xTicks) == nstrips))
		then
		(xtick = nth(strip xTicks))
		else
		(xtick = nil)
	    )
	    if( (yTicks && (length(yTicks) == nstrips))
		then
		(ytick = nth(strip yTicks))
		else
		(ytick = nil)
	    )
	    fprintf(targetFile "%s\n" "\\begin{axis}[")
	    if( !minorGrid
		then
		fprintf(targetFile "%s\n" "grid=major,")
		else
		if( (nth(0 
			nth(strip minorGrid)
		    ) != 0)
		    then
		    fprintf(targetFile "%s\n%s\n%s%L%s\n" "grid=both,","minor grid style={draw=gray!20, very thin},","minor x tick num=" 
			nth(0 
			    nth(strip minorGrid)
			) ","
		    )
		)
		if( (nth(1 
			nth(strip minorGrid)
		    ) != 0)
		    then
		    fprintf(targetFile "%s\n%s\n%s%L%s\n" "grid=both,","minor grid style={draw=gray!20, very thin},","minor y tick num=" 
			nth(1 
			    nth(strip minorGrid)
			) ","
		    )
		)
	    )
	    if( (noAxes == 1)
		then
		fprintf(targetFile "%s\n" "hide axis,")
	    )
	    if( precision
		then
		fprintf(targetFile "%s%L%s\n" "/pgf/number format/precision=" precision ",")
	    )
	    if( xmode
		then
		if( (xmode == "log")
		    then
		    fprintf(targetFile "%s\n" "xmode=log,")
		)
	    )
	    if( ymode
		then
		if( (ymode == "log")
		    then
		    fprintf(targetFile "%s\n" "ymode=log,")
		)
	    )
	    if( (xlabel && (xticklabel != 0))
		then
		fprintf(targetFile "%s%s%s\n" "xlabel={" xlabel "},")
	    )
	    if( (ylabel && (yticklabel != 0))
		then
		fprintf(targetFile "%s%s%s\n" "ylabel={" ylabel "},")
	    )
	    if( xlimit
		then
		fprintf(targetFile "%s%L%s%L%s\n" "xmin=" 
		    nth(0 xlimit) ",xmax="
		    nth(1 xlimit) ","
		)
	    )
	    if( ylimit
		then
		fprintf(targetFile "%s%L%s%L%s\n" "ymin=" 
		    nth(0 ylimit) ",ymax="
		    nth(1 ylimit) ","
		)
	    )
	    ; Write x-axis tick locations
	    if( xtick
		then
		if( (length(xtick) != 0)
		    then
		    fprintf(targetFile "%s" "xtick={")
		    for( ll 0 (length(xtick) - 2)
			fprintf(targetFile "%L%s" 
			    nth(ll xtick) ","
			)
		    ) ; loop through data points
		    fprintf(targetFile "%L%s\n" 
			nth((length(xtick) - 1) xtick) "},"
		    )
		)
	    ) ; if(xtick
	    ; Write y-axis tick locations
	    if( ytick
		then
		if( (length(ytick) != 0)
		    then
		    fprintf(targetFile "%s" "ytick={")
		    for( ll 0 (length(ytick) - 2)
			fprintf(targetFile "%L%s" 
			    nth(ll ytick) ","
			)
		    )
		    fprintf(targetFile "%L%s\n" 
			nth((length(ytick) - 1) ytick) "},"
		    )
		)
	    ) ; if(ytick
	    ; Suppress the numbers on the axis if so specified
	    if( (xticklabel == 0)
		then
		fprintf(targetFile "%s\n" "xticklabels={,,},")
		fprintf(targetFile "%s\n" "scaled x ticks = false,")
	    )
	    if( (yticklabel == 0)
		then
		fprintf(targetFile "%s\n" "yticklabels={,,},")
	    )
	    fprintf(targetFile "%s\n" "legend pos=north east,")
	    fprintf(targetFile "%s%s%s\n" "width=" width ",")
	    fprintf(targetFile "%s%L%s" "height=" stripheight width)
	    if(nth(strip additionalAxisArgs) 
	    	then 
		fprintf(targetFile "%s\n%s%s\n" "," nth(strip additionalAxisArgs) "]") 
		else 
		fprintf(targetFile "%s\n" "]")
	    ) 
	    ; Plot the waveforms on each strip
	    (nstripwaves = length(nth(strip waveAssign0)))
	    for( stripwave 0 (nstripwaves - 1)
		; Get the waveform points and colors
		(wave = nth(stripwave 
			nth(strip waveAssign0)
		    ))
		(xyData = abWaveToList(nth((wave - 1) waves)))
		color = nth((wave-1) colors)
		if( color
		then
		addPlotLine = sprintf(nil "%s%s%s%s" addPlotLine0 "," color "]")
		else
		addPlotLine = sprintf(nil "%s%s" addPlotLine0 "]")
		)
		fprintf(targetFile "\n%s%s\n" "\\addplot" addPlotLine)
		fprintf(targetFile "%s\n" "coordinates{")
		if( (legends && nth((wave - 1) legends))
		    then
		    if( !legendText
			then
			(legendText = nth((wave - 1) legends))
			else
			(legendText = sprintf(nil "%s%s%s" legendText "," 
				nth((wave - 1) legends)
			    ))
		    )
		)
		(lenData = floor((length(xyData) / undersample)))
		printf("%s%d%s%d%s%d%s\n" "Strip " 
		    (strip + 1) ", Wave" 
		    (stripwave + 1)
		    ": " lenData " data points "
		)
		; loop through data points
		for( kk 0 (lenData - 1)
		    fprintf(targetFile "%s" "(")
		    fprintf(targetFile "%L" 
			nth(0 
			    nth((kk * undersample) xyData)
			)
		    )
		    fprintf(targetFile "%s" ",")
		    fprintf(targetFile "%L" 
			nth(1 
			    nth((kk * undersample) xyData)
			)
		    )
		    fprintf(targetFile "%s\n" ")")
		) ; loop through data points
		fprintf(targetFile "%s" "};\n")
	    ) ; Plot the waveforms on each strip
		; Add the legends
	    if( legendText
		then
		fprintf(targetFile "%s%s%s\n" "\\legend{" legendText "}")
	    )
	    
	    if(textLabels then
		if(nth(strip textLabels) then 
		    for(kk 0 
			(length(nth(strip textLabels)) - 1) 
			if(nth(2 nth(kk nth(strip textLabels) ) ) then 
			    (labelx = nth(0 nth(kk nth(strip textLabels) ) )) 
			    (labely = nth(1 nth(kk nth(strip textLabels) ) )) 
			    (labeltext = nth(2 nth(kk nth(strip textLabels) ) ))
			    if(nth(3 nth(kk nth(strip textLabels) ) ) then
			    	(labelcolor = nth(3 nth(kk nth(strip textLabels) ) ))
			    	fprintf(targetFile "%s%s%s%L%s%L%s%s%s\n" "\\node[anchor=west, text=" labelcolor "] at (axis cs:" labelx "," labely ") {" labeltext "};" )
			    	else
			    	fprintf(targetFile "%s%L%s%L%s%s%s\n" "\\node[anchor=west] at (axis cs:" labelx "," labely ") {" labeltext "};" )			    	
			    )
			)
		    )
		)
	    ) 
	    fprintf(targetFile "%s\n" axisFinishLine)
	    ; Add vertical separation between strips if specified
	    if( stripVsep
		then
		if( !(strip == (nstrips - 1))
		    then
		    fprintf(targetFile "%s%s%s\n" "[" stripVsep "]")
		)
	    ) ; if( stripVsep
	) ; loop through strips
	; Finish writing into the output file
	fprintf(targetFile "%s" picFinishLine) 
	printf("%s%s\n" "Finished writing " fileName0) 
	close(targetFile)
	; Generate the pdf output
	if( (genPdf == 1)
	    then
		; Write the LaTeX file for getting pdf outputs
	    (texFileName = sprintf(nil "%s%s" fileNameBase ".tex"))
	    csh(sprintf(nil "%s%s%s%s" "cp -f " headerFilePath "/headerFile.tex " texFileName))
	    (targetFile = outfile(texFileName "a"))
	    fprintf(targetFile "%s%s%s\n" "\\input{" fileName0 "}")
	    fprintf(targetFile "%s\n" "\\end{document}")
	    close(targetFile)
	    csh(sprintf(nil "%s%s%s" "pdflatex -interaction=nonstopmode " texFileName " > pdflatexmsgs"))
	    printf("%s%s%s\n" "Finished compiling " fileNameBase ".tex")
	    if( (retainTexFile != 1)
		then
		csh(sprintf(nil "%s%s" "rm -f " texFileName))
		else
		printf("%s\n" "Retaining the LaTeX file")
	    )
	    csh(sprintf(nil "%s%s%s" "rm -f " fileNameBase ".log"))
	    csh(sprintf(nil "%s%s%s" "rm -f " fileNameBase ".aux"))
	    csh(sprintf(nil "%s%s%s" "rm -f " fileNameBase ".out"))
	    csh(sprintf(nil "%s" "rm -f pdflatexmsgs"))
	) ; if genPdf==1
    ) ; let
) ; procedure nkWaveToTikz

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; If there are fewer variables than the number of strips, assign the last one to the rest
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
procedure(assignStripVars(var0 nstrips) 
    let((var1) 
	if((length(var0) < nstrips) then 
	    (var1 = cons(nth((length(var0) - 1) var0) nil)) ; Copy the last element of var0 as var1(list) 
	    for(kk 
		length(var0) 
		(nstrips - 2) 
		(var1 = cons(nth((length(var0) - 1) var0) var1)) ; Repeat the last element of var0 into var1 for unassigned ones
	    ) 
	    for(kk 0 
		(length(var0) - 1) 
		(var1 = cons(nth((length(var0) - 1 - kk) var0) var1)) ; Copy the elements of var0 into var1
	    )
	    else 
	    (var1 = var0)
	) 
	(var0 = var1)
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; If there are fewer colors than the number of waveforms, assign the rest to nil so that they are auto assigned
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
procedure(assignWaveColors(var0 nwaves) 
    let((var1) 
	if((length(var0) < nwaves) then 
	    var1 = nil ; Copied from assignStripVars; In this case the nil color is assigned to unassigned ones
	    for(kk 
		length(var0) 
		(nwaves - 1) 
		(var1 = cons(nil var1)) ; Repeat nil for unassigned ones
	    ) 
	    for(kk 0 
		(length(var0) - 1) 
		(var1 = cons(nth((length(var0) - 1 - kk) var0) var1)) ; Copy the elements of var0 into var1
	    )
	    else 
	    (var1 = var0)
	) 
	(var0 = var1)
    )
)

/************************************************************************/
/* abWaveToList.il

Author A.D.Beckett
Group Custom IC (UK), Cadence Design Systems Ltd.
Language SKILL
Date Nov 17, 2003
Modified
By

Convert a waveform to a list

***************************************************

SCCS Info: @(#) abWaveToList.il 11/17/03.15:08:15 1.1

*/

/************************************************************************
* *
* (abWaveToList wave @key transpose) *
* *
* Take a waveform object, and return it as a list of xy pairs. Or *
* if transpose is set, it returns a list of x values followed by a list *
* of y values. *
* *
************************************************************************/

(procedure (abWaveToList wave @key transpose)
(let (xList yList xyList len
(xVec (drGetWaveformXVec wave))
(yVec (drGetWaveformYVec wave))
)
(setq len (drVectorLength xVec))
;-----------------------------------------------------------------
; Return value of this if is the list
;-----------------------------------------------------------------
(if transpose
(progn
(for i 0 (sub1 len)
(setq xList (tconc xList (drGetElem xVec i)))
(setq yList (tconc yList (drGetElem yVec i)))
)
(list (car xList) (car yList))
)
; else
(progn
(for i 0 (sub1 len)
(setq xyList (tconc xyList (list (drGetElem xVec i)
(drGetElem yVec i))))
)
(car xyList)
)
) ; if
) ; let
) ; procedure


