<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
  <html>
  <head></head>
  <style type="text/css">

   p.desc{
     white-space:nowrap;
   }

   table.pretty {
    margin: 1em 1em 1em 2em;
    background: whitesmoke;
    border-collapse: collapse;
   }

   table.pretty th, table.pretty td {
    border: 1px gainsboro solid;
    padding: 0.2em;
   }

   table.pretty th {
    background: gainsboro;
    text-align: left;
   }

   table.pretty caption {
    margin-left: inherit;
    margin-right: inherit;
    white-space:nowrap;
   }
  </style>
  <body>
  <h2>Macro Overview</h2>

  The following macros can be overloaded on host level.
  <table class="pretty">
    <tr>
      <th>Name</th>
      <th>Default</th>
    </tr>
    <xsl:for-each select="zabbix_export/templates/template/macros/macro">
    <tr>
      <td><xsl:value-of select="macro"/></td>
      <td><xsl:value-of select="value"/></td>
    </tr>
    </xsl:for-each>
  </table>


  <h1>Static Elements</h1>
  <h2>Trigger Overview</h2>
  <table class="pretty">
    <tr>
      <th>Name</th>
      <th>Description</th>
      <th>Priority</th>
      <th>Expression</th>
      <th>Dependencies</th>
    </tr>
    <xsl:for-each select="zabbix_export/triggers/trigger">
    <tr>
      <td><xsl:value-of select="name"/></td>
      <td><xsl:value-of select="description"/></td>
      <xsl:choose>
         <xsl:when test="priority='INFORMATION'"><td style="background-color:#FFFF00;">Information</td></xsl:when>
         <xsl:when test="priority='WARNING'"><td style="background-color:#FFFF00;">Warning</td></xsl:when>
         <xsl:when test="priority='AVERAGE'"><td style="background-color:#FF0000;">Average</td></xsl:when>
         <xsl:when test="priority='HIGH'"><td style="background-color:#FF0000;">High</td></xsl:when>
         <xsl:when test="priority='DISASTER'"><td style="background-color:#FF0000;">Disaster</td></xsl:when>
         <xsl:otherwise><td>NOT CLASSIFIED</td></xsl:otherwise>
      </xsl:choose>
      <td><tt><xsl:value-of select="expression"/></tt></td>
      <td><tt>
      <xsl:for-each select="dependencies/dependency">
         <xsl:value-of select="name"/><br></br>
      </xsl:for-each>
      </tt></td>
    </tr>
    </xsl:for-each>
  </table>

  <h2>Graph Overview</h2>
  <table class="pretty">
    <tr>
      <th>Name</th>
      <th>Elements</th>
    </tr>
    <xsl:for-each select="zabbix_export/graphs/graph">
    <tr>
      <td><xsl:value-of select="name"/></td>
      <td><tt><xsl:for-each select="graph_items/graph_item">
         <xsl:value-of select="item/key"/><br/>
      </xsl:for-each></tt></td>
    </tr>
    </xsl:for-each>
  </table>


  <h2>Item Overview</h2>
  <table class="pretty">
    <tr>
      <th>Type</th>
      <th>Name</th>
      <th>Key</th>
      <th>Description</th>
      <th>Interval (sec)</th>
      <th>History Days</th>
      <th>Trend Days</th>
    </tr>
    <xsl:for-each select="zabbix_export/templates/template/items/item">
    <tr>
      <td><xsl:value-of select="type"/></td>
      <td><xsl:value-of select="name"/></td>
      <td><tt><xsl:value-of select="key"/></tt></td>
      <td><xsl:value-of select="description"/></td>
      <td><xsl:value-of select="delay"/></td>
      <td><xsl:value-of select="history"/></td>
      <td><xsl:value-of select="trends"/></td>
    </tr>
    </xsl:for-each>
  </table>

  <xsl:for-each select="zabbix_export/templates/template/discovery_rules/discovery_rule">
  <h1>Discovery rule "<xsl:value-of select="name"/>"</h1>

   <table class="pretty">
    <tr>
      <th>Name</th>
      <th>Value</th>
    </tr>
    <tr><td>Name</td><td><xsl:value-of select="name"/></td></tr>
    <tr><td>Key</td><td><xsl:value-of select="key"/></td></tr>
    <tr>
      <td>Type</td>
      <td><xsl:value-of select="type"/></td>
     </tr>
     <tr><td>Delay</td><td><xsl:value-of select="delay"/></td></tr>
  </table>


  <h2>Trigger Overview</h2>
  <table class="pretty">
    <tr>
      <th>Name</th>
      <th>Description</th>
      <th>Priority</th>
      <th>Expression</th>
      <th>Dependencies</th>
    </tr>
    <xsl:for-each select="trigger_prototypes/trigger_prototype">
    <tr>
      <td><xsl:value-of select="name"/></td>
      <td><xsl:value-of select="description"/></td>
      <xsl:choose>
         <xsl:when test="priority='INFORMATION'"><td style="background-color:#FFFF00;">Information</td></xsl:when>
         <xsl:when test="priority='WARNING'"><td style="background-color:#FFFF00;">Warning</td></xsl:when>
         <xsl:when test="priority='AVERAGE'"><td style="background-color:#FF0000;">Average</td></xsl:when>
         <xsl:when test="priority='HIGH'"><td style="background-color:#FF0000;">High</td></xsl:when>
         <xsl:when test="priority='DISASTER'"><td style="background-color:#FF0000;">Disaster</td></xsl:when>
         <xsl:otherwise><td>NOT CLASSIFIED</td></xsl:otherwise>
      </xsl:choose>
      <td><tt><xsl:value-of select="expression"/></tt></td>
      <td><tt>
      <xsl:for-each select="dependencies/dependency">
         <xsl:value-of select="name"/><br></br>
      </xsl:for-each>
      </tt></td>
    </tr>
    </xsl:for-each>
  </table>

  <h2>Graph Overview</h2>
  <table class="pretty">
    <tr>
      <th>Name</th>
      <th>Elements</th>
    </tr>
    <xsl:for-each select="graph_prototypes/graph_prototype">
    <tr>
      <td><xsl:value-of select="name"/></td>
      <td><tt><xsl:for-each select="graph_items/graph_item">
         <xsl:value-of select="item/key"/><br/>
      </xsl:for-each></tt></td>
    </tr>
    </xsl:for-each>
  </table>


  <h2>Item Overview</h2>
  <table class="pretty">
    <tr>
      <th>Type</th>
      <th>Name</th>
      <th>Key</th>
      <th>Description</th>
      <th>Interval (sec)</th>
      <th>History Days</th>
      <th>Trend Days</th>
    </tr>
    <xsl:for-each select="item_prototypes/item_prototype">
       <tr>
      <td><xsl:value-of select="type"/></td>
      <td><xsl:value-of select="name"/></td>
      <td><tt><xsl:value-of select="key"/></tt></td>
      <td><xsl:value-of select="description"/></td>
      <td><xsl:value-of select="delay"/></td>
      <td><xsl:value-of select="history"/></td>
      <td><xsl:value-of select="trends"/></td>
    </tr>
    </xsl:for-each>
  </table>
  </xsl:for-each>

  </body>
  </html>
</xsl:template>
</xsl:stylesheet> 
