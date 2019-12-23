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
         <xsl:when test="priority='0'"><td style="background-color:#efefef;">Not classified</td></xsl:when>
         <xsl:when test="priority='1'"><td style="background-color:#FFFF00;">Information</td></xsl:when>
         <xsl:when test="priority='2'"><td style="background-color:#FFFF00;">Warning</td></xsl:when>
         <xsl:when test="priority='3'"><td style="background-color:#FF0000;">Average</td></xsl:when>
         <xsl:when test="priority='4'"><td style="background-color:#FF0000;">High</td></xsl:when>
         <xsl:when test="priority='5'"><td style="background-color:#FF0000;">Disaster</td></xsl:when>
         <xsl:otherwise><xsl:value-of select="priority"/><td>ERROR - Unknown</td></xsl:otherwise>
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
      <xsl:choose>
         <xsl:when test="type='0'"><td><p class="desc">Zabbix Agent</p></td></xsl:when>
         <xsl:when test="type='2'"><td><p class="desc">Zabbix Trapper</p></td></xsl:when>
         <xsl:when test="type='3'"><td><p class="desc">Simple check</p></td></xsl:when>
         <xsl:when test="type='7'"><td><p class="desc">Zabbix Agent (active)</p></td></xsl:when>
         <xsl:when test="type='10'"><td><p class="desc">External check</p></td></xsl:when>
         <xsl:when test="type='15'"><td><p class="desc">Calculated</p></td></xsl:when>
         <xsl:otherwise><xsl:value-of select="state"/><td><p class="desc">ERROR - Unknown</p></td></xsl:otherwise>
      </xsl:choose>
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
      <xsl:choose>
         <xsl:when test="type='0'"><td><p class="desc">Zabbix Agent</p></td></xsl:when>
         <xsl:when test="type='2'"><td><p class="desc">Zabbix Trapper</p></td></xsl:when>
         <xsl:when test="type='3'"><td><p class="desc">Simple check</p></td></xsl:when>
         <xsl:when test="type='7'"><td><p class="desc">Zabbix Agent (active)</p></td></xsl:when>
         <xsl:when test="type='10'"><td><p class="desc">External check</p></td></xsl:when>
         <xsl:when test="type='15'"><td><p class="desc">Calculated</p></td></xsl:when>
         <xsl:otherwise><xsl:value-of select="state"/><td><p class="desc">ERROR - Unknown</p></td></xsl:otherwise>
      </xsl:choose>
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
         <xsl:when test="priority='0'"><td style="background-color:#efefef;">Not classified</td></xsl:when>
         <xsl:when test="priority='1'"><td style="background-color:#FFFF00;">Information</td></xsl:when>
         <xsl:when test="priority='2'"><td style="background-color:#FFFF00;">Warning</td></xsl:when>
         <xsl:when test="priority='3'"><td style="background-color:#FF0000;">Average</td></xsl:when>
         <xsl:when test="priority='4'"><td style="background-color:#FF0000;">High</td></xsl:when>
         <xsl:when test="priority='5'"><td style="background-color:#FF0000;">Disaster</td></xsl:when>
         <xsl:otherwise><xsl:value-of select="priority"/><td>ERROR - Unknown</td></xsl:otherwise>
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
      <xsl:choose>
         <xsl:when test="type='0'"><td><p class="desc">Zabbix Agent</p></td></xsl:when>
         <xsl:when test="type='2'"><td><p class="desc">Zabbix Trapper</p></td></xsl:when>
         <xsl:when test="type='3'"><td><p class="desc">Simple check</p></td></xsl:when>
         <xsl:when test="type='7'"><td><p class="desc">Zabbix Agent (active)</p></td></xsl:when>
         <xsl:when test="type='10'"><td><p class="desc">External check</p></td></xsl:when>
         <xsl:when test="type='15'"><td><p class="desc">Calculated</p></td></xsl:when>
         <xsl:otherwise><xsl:value-of select="state"/><td><p class="desc">ERROR - Unknown</p></td></xsl:otherwise>
      </xsl:choose>
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
