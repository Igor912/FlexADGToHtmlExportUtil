package
{
	import flash.net.FileReference;
	import flash.utils.ByteArray;

	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.WhiteSpaceCollapse;

	import mx.collections.ICollectionView;
	import mx.collections.IViewCursor;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumnGroup;

	import spark.utils.TextFlowUtil;

	/**
	 *
	 * @author Ihor Khomiak
	 */
	public class ADGToHtmlExportUtil
	{
		public function ADGToHtmlExportUtil()
		{
		}

		/**
		 *
		 * Generating html file and exporting AdvancedDataGrid data to html table.
		 *
		 * @param adg
		 * @param fileName
		 * @param encoding
		 */
		public function saveAdvancedDataGridAsHTMLFile( adg:AdvancedDataGrid, fileName:String, encoding:String = "utf-16" ):void
		{
			var htmlString:String = advancedDataGridToHTMLTable( adg );
			var bytes:ByteArray = new ByteArray();
			// if using UTF-16, prefix file with BOM (little-endian)
			if ( encoding == "utf-16" )
			{
				bytes.writeByte( 0xFF );
				bytes.writeByte( 0xFE );
				bytes.writeMultiByte( htmlString, encoding );
			}
			else
				bytes.writeMultiByte( htmlString, encoding );
			// prompt the user with a save location
			// note: FileReference requires a minimum flash player version of 10
			var fileReference:FileReference = new FileReference();
			fileReference.save( bytes, fileName );
			fileReference = null;
		}

		/**
		 *	Parsing and formating AdvancedDataGrid data.
		 *
		 * @param adg
		 * @return htmlString:String
		 */
		public function advancedDataGridToHTMLTable( adg:AdvancedDataGrid ):String
		{
			//  ##_headerName## will be replaced by generated html header text
			//  ##_tabelContent## will be replaced by generated html table contant text
			var htmlString:String = "<html><head><title>ADG EXPORT</title></head><body>" +
				"<br/><br/><table border=1><thead><tr>##_headerName##</tr></thead>"+
				"<tbody>##_tabelContent##</tbody></table></body></html>";

			var headerHTML:String = "";
			var headerItems:Array;
			var dataHTML:String = "";
			var dataItems:Array;
			var columns:Array = adg.groupedColumns ? adg.groupedColumns : adg.columns;
			var column:AdvancedDataGridColumn;
			var headerGenerated:Boolean = false;
			var cursor:IViewCursor = ( adg.dataProvider as ICollectionView ).createCursor();

			// loop through rows
			while (!cursor.afterLast)
			{
				var obj:Object = null;
				obj = cursor.current;
				dataItems = new Array();
				headerItems = new Array();
				// loop through all columns for the row
				for each ( column in columns )
				{
					// if the column is not visible or the header text is not defined (e.g., a column used for a graphic),
					// do not include it in the HTML dump
					if ( !column.visible || !column.headerText )
						continue;

					// depending on whether the current column is a group or not, export the data differently
					if ( column is AdvancedDataGridColumnGroup )
					{
						for each ( var subColumn:AdvancedDataGridColumn in ( column as AdvancedDataGridColumnGroup ).children )
						{
							// if the sub-column is not visible or the header text is not defined (e.g., a column used for a graphic),
							// do not include it in the html dump
							if ( !subColumn.visible || !subColumn.headerText )
								continue;
							dataItems.push( obj ? subColumn.itemToLabel(obj) : "" );
							if ( !headerGenerated )
								headerItems.push( column.headerText + ": " + subColumn.headerText );
						}
					}
					else
					{
						var labelString:String = formatHTMLFlowText( column.itemToLabel( obj ));
						dataItems.push( obj ? labelString : "");
						if ( !headerGenerated )
							headerItems.push( column.headerText );						
					}
				}
				// append a HTML generated line of our data
				dataHTML += formatRowString( dataItems );
				// if our header HTML has not been generated yet, do so; this should only occur once
				if ( !headerGenerated )
				{
					headerHTML = formatHeaderString( headerItems );
					headerGenerated = true;
				}
				// move to our next item
				cursor.moveNext();
			}

			// set references to null:
			headerItems = null;
			dataItems = null;
			columns = null;
			column = null;
			cursor = null;

			htmlString = htmlString.replace( "##_headerName##", headerHTML );   //inserting generated html table header text to main htmlString
			htmlString = htmlString.replace( "##_tabelContent##", dataHTML );   //inserting generated html table content text to main htmlString

			// return combined string
			return htmlString;
		}

		private function formatRowString( items:Array ):String
		{
			var resultString:String = '<tr>';
			for each ( var headerItem:String in items ) 
			{
				resultString += "<td>" + headerItem + "</td>";
			}	
			resultString += '</tr>';
			return resultString;
		}

		private function formatHeaderString( items:Array ):String
		{
			var resultString:String = '';
			for each ( var headerItem:String in items ) 
			{
				resultString += "<th bgcolor=#736F6E>" + headerItem + "</th>";
			}

			return resultString;
		}

		private function formatHTMLFlowText( labelString:String ):String  //if some field has data with html tags and styles - this method will format this text
		{
			if( labelString.search( '<TextFlow' ) == -1 )  // if labelString is not html text
			{
				return labelString;
			}
			else
			{
				var textFlow:TextFlow = TextFlowUtil.importFromXML( new XML( labelString ), WhiteSpaceCollapse.PRESERVE );
				return TextConverter.export( textFlow, TextConverter.TEXT_FIELD_HTML_FORMAT, ConversionType.STRING_TYPE ).toString();
			}
		}
	}
}

