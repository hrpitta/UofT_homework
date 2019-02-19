

Sub money_grow()

    ' --------------------------------------------
    ' LOOP THROUGH ALL SHEETS
    ' --------------------------------------------
    For Each ws in Worksheets

        ' --------------------------------------------
        ' INSERT THE VALUES
        ' --------------------------------------------

        ' Created a Variable to Hold Worksheet Name, Last Row, Last Column, and Year
        Dim WorksheetName As String

        ' Determine the Last Row
        LastRow = ws.Cells(Rows.Count, 1).End(xlUp).Row

        ' Grabbed the WorksheetName
        WorksheetName = ws.Name
        ' MsgBox WorksheetName

        ' Add the Header
        ws.Cells(1, 9).Value = "Ticker"
		ws.Cells(1, 10).Value = "Yearly Change"
		ws.Cells(1, 11).Value = "Percent Change"
		ws.Cells(1, 12).Value = "Total Stock Volume"

        ' --------------------------------------------

        ' Set an initial variable for the ticker name
        Dim ticker As String
        Dim total_stock As Double
		total_stock = 0
		Dim close_value As Double
		close_value = 0
		Dim open_value As Double
		open_value = 0
		Dim final_market As Double
		final_market = 0
		Dim difference As Double
		difference = 0
		Dim percent_change As Double
		percent_change = 0
		
		
		' Keep track of the row in the summary table
        Dim Summary_Table_Row As Integer
        Summary_Table_Row = 2
		
		'Set Initial Open Value
        open_value = Cells(2, 3).Value
		
        ' Loop through all stocks
        For i = 2 To lastrow
        
          ' Check the same ticker...
          If ws.Cells(i+1, 1).Value <> ws.Cells(i, 1).Value Then
        
            ' Sum the value of the stock
            total_stock = total_stock + ws.Cells(i, 7).Value
			
			' Set the close value
			close_value = ws.Cells(i, 6).Value
			
			' Difference close and open
            difference = close_value - open_value
			
			' Set the ticker name
			ticker = ws.Cells(i, 1).Value
			
			' Print the Ticker
            ws.Range("I" & Summary_Table_Row).Value = ticker
          
            ' Print the Stock Amount
            ws.Range("L" & Summary_Table_Row).Value = total_stock
            
            ' Print the value difference
            ws.Range("J" & Summary_Table_Row).Value = difference
			
			' Print the Percentage Difference
			If (open_value = 0 And close_value = 0) Then
                    percent_change = 0
                ElseIf (open_value = 0 And close_value <> 0) Then
                    percent_change = 1
                Else
                    percent_change = difference / open_value
                End If
			
            ws.Range("K" & Summary_Table_Row).Value = percent_change
            ws.Range("K" & Summary_Table_Row).NumberFormat = "0.00%" 
			
            ' Add one to the summary table row
            Summary_Table_Row = Summary_Table_Row + 1
            
            ' Reset the values
            total_stock = 0
			open_value = ws.Cells(i,3).Value
			
          ' If the cell immediately following a row is the same ticker...
          Else
          
            ' Add to the Stock Total
            total_stock = total_stock + ws.Cells(i, 7).Value
			
			' Final market percentage
			' final_market = ws.Cells(i,6).value / open_value
				
          
          End If
        
        Next i
		
		' Determine the Last Row of Yearly Change per WS
        YCLastRow = WS.Cells(Rows.Count, 9).End(xlUp).Row
        ' Set the Cell Colors
        For j = 2 To YCLastRow
            If (Cells(j, 10).Value > 0 Or Cells(j, 10).Value = 0) Then
                Cells(j, 10).Interior.ColorIndex = 10
            ElseIf Cells(j, 10).Value < 0 Then
                Cells(j, 10).Interior.ColorIndex = 3
            End If
        Next j
        
    ' --------------------------------------------
    ' Next Worksheet
    ' --------------------------------------------
    Next ws


End Sub

