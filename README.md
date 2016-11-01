# Adobe Flex/AIR/ActionScript3 AdvencedDataGrid To Html Tables Export Util

  Util for export Flex AdvancedDataGrid to HTML tables.
  
### Example of using in the code:
  
- Import ADGToHtmlExportUtil to your AS3 class/component;
- Create object of class ADGToHtmlExportUtil;
- Call method saveAdvancedDataGridAsHTMLFile with parameters: advancedDataGrid object and name of html file you exporting to.
	
```
var htmlExport:ADGToHtmlExportUtil = new ADGToHtmlExportUtil();
htmlExport.saveAdvancedDataGridAsHTMLFile( activeDataGrid, 'dataGridToHTMLTable.html' );
```
