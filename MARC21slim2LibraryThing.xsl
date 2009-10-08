<?xml version="1.0" encoding="UTF-8" standalone="yes"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:marc="http://www.loc.gov/MARC21/slim"
  xmlns:hold="http://open-ils.org/spec/holdings/v1"
  version="1.0">
  <xsl:output method="text" doctype-public="-//W3C/DTD HTML 4.01 Transitional//EN" doctype-system="http://www.w3.org/TR/html4/strict.dtd" />

<!-- tab character &#x9; better implementation might be make a variable and have "columns" in internal xml.  Then recurse over that adding xml-->
  <xsl:template match="/">
    <xsl:text>book id</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>title</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>author (last, first)</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>author (first last)</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>other authors</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>publication</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>date</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>ISBN</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>series</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>source</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>language 1</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>language 2</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>original language</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>LCC</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>DDC</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>BCID</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>date entered</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>date entered</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>date entered</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>date entered</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>stars</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>review</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>summary</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>comments</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>private comments</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>your copies</xsl:text><xsl:text>&#x9;</xsl:text>
    <xsl:text>encoding</xsl:text>
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates select="*" />
  </xsl:template>

  <!-- 
   doing a "pull" method, mainly due to
   the structured nature of the output.

   probably should also have some sort of character 
   filter to make sure we don't have tabs or 
   something in the input
  -->

  <xsl:template match="text()" />

  <xsl:template match="marc:record">
     <!-- id of record...probably should be more complex -->
     <xsl:value-of select="marc:controlfield[@tag='001']" /><xsl:text>&#x9;</xsl:text>

     <!-- title -->
     <!-- need to clean up metadata -->
     <xsl:value-of select="marc:datafield[@tag='245']/marc:subfield[@code='a']" />
     <xsl:value-of select="marc:datafield[@tag='245']/marc:subfield[@code='b']" />
     <xsl:text>&#x9;</xsl:text>

     <!-- author (last, first) -->
     <xsl:choose>
        <xsl:when test="marc:datafield[@tag='100'] | marc:datafield[@tag='110']">
          <xsl:for-each select="marc:datafield[@tag='100'] | marc:datafield[@tag='110']">
	    <xsl:value-of select="substring-before(marc:subfield[@code='a'],'.')" />
            <xsl:text>&#x9;</xsl:text>
          </xsl:for-each>  
        </xsl:when>
	<!--  since $c can have multiple authors would have to 
              attempt to extract, commenting out for now-->
        <!--
        <xsl:when
        <xsl:when test="marc:datafield[@tag='245']">
           <xsl:value-of select="marc:subfield[@code='c']" />
        </xsl:when>
        -->
    </xsl:choose>

    <!-- author (first last) -->
    <xsl:if test="contains(marc:datafield[@tag='100']/marc:subfield[@code='a'],',')">
	<xsl:call-template name="reverseName">
           <xsl:with-param name="name" select="marc:datafield[@tag='100']/marc:subfield[@code='a']" />
        </xsl:call-template>    
   <!-- should not assume space or period, should be more complex -->
    </xsl:if>
    <xsl:text>&#x9;</xsl:text>
    
    <!-- other authors (how are they internally delimited?) -->
    <!-- look in 7X0s, even better would be to compare 245 c and 1X0 -->
    <xsl:variable name="OtherAuthors">
	<xsl:for-each select="marc:datafield[@tag='700']">
          <xsl:text>, </xsl:text>
          <xsl:call-template name="reverseName">
            <xsl:with-param name="name" select="marc:subfield[@code='a']" />
          </xsl:call-template>
	</xsl:for-each>

	<xsl:for-each select="marc:datafield[@tag='710'] | marc:datafield[@tag='711'] | marc:datafield[@tag='720']">
          <xsl:text>, </xsl:text>
	  <xsl:value-of select="marc:subfield[@code='a']" />
	</xsl:for-each>


	<xsl:for-each select="marc:datafield[@tag='700']">
          <xsl:text>, </xsl:text>
          <xsl:call-template name="reverseName">
            <xsl:with-param name="name" select="marc:subfield[@code='a']" />
          </xsl:call-template>
	</xsl:for-each>

    </xsl:variable>

    <xsl:if test="$OtherAuthors != ''">
       <xsl:value-of select="substring($OtherAuthors,3)" />
    </xsl:if>
    <xsl:text>&#x9;</xsl:text>
    
    <!-- examples from LT 
         O'Reilly Media (2000), Paperback, 1092 pages
         Brewers Publications (2006), Edition: 3rd, Paperback, 400 pages  -->
    <!-- shouldn't be assuming the markup, but can improve later -->

    <xsl:variable name="pubinfo">
      <xsl:text>), </xsl:text>
      <xsl:value-of select="substring-before(marc:datafield[@tag='260']/marc:subfield[@code='b'],',')" />
      <xsl:text> </xsl:text>
      <xsl:text>(</xsl:text>
      <!-- not bothering to parse out publisher date, probably should
           or at least do smarter date1/date2 hashing.  That really
           should be done in some general library -->
      <xsl:value-of select="substring(marc:leader,12,4)" />
      <xsl:text>)</xsl:text>
 
      <xsl:if test="marc:datafield[@tag='250']">
         <xsl:text>, Edition: </xsl:text>
         <xsl:value-of select="marc:datafield[@tag='250']/marc:subfield[@code='a']" />
      </xsl:if>

      <!-- need to get Paperback/hardcover, best I can come up with is
           getting first isbn and trying to yank it out, maybe doing some
           pattern matching -->
      <xsl:if test="marc:datafield[@tag='020']">
         <xsl:choose>
           <xsl:when test="contains(marc:datafield[@tag='020'][1]/marc:subfield[@code='a'],'pbk')">
             <xsl:text>, Paperback</xsl:text>
           </xsl:when>
           <xsl:when test="contains(marc:datafield[@tag='020'][1]/marc:subfield[@code='a'],'(') 
                           and
                           contains(marc:datafield[@tag='020'][1]/marc:subfield[@code='a'],')')">
             <xsl:text>, </xsl:text>
             <xsl:value-of select="substring-before(substring-after(marc:datafield[@tag='020'][1]/marc:subfield[@code='a'],'('),')')" />
           </xsl:when> 
         </xsl:choose>        
      </xsl:if>
      
      <!-- we want to try to extract a series of digits before p.
           needs to be more flexible (ie if space isn't there it's fine... -->
      <xsl:if test="contains(marc:datafield[@tag='300']/marc:subfield[@code='a'],' p.')">
        <!-- so, ucky quick solution..do a template recursion that 
             goes through and finds the last "chunk".  Thought it would
             be quicker to use reverse, but don't see it. 
             Notice this will not be accurate as it throws out intros
             and doesn't include a lot of pages-->
        <xsl:text>, </xsl:text>
        <xsl:call-template name="extractPages">
           <xsl:with-param name="chunk" select="normalize-space(substring-before(marc:datafield[@tag='300']/marc:subfield[@code='a'],' p.'))" />
        </xsl:call-template>
        <xsl:text> pages</xsl:text>
      </xsl:if> 


    </xsl:variable>
    <xsl:if test="$pubinfo != ''">
       <xsl:value-of select="substring($pubinfo,3)" />
    </xsl:if>
    <xsl:text>&#x9;</xsl:text>

    <!-- date (cheating and just using date 1, 
         should clean it up and make sure no 19uu etc-->
    <xsl:value-of select="substring(marc:leader,12,4)" />
    <xsl:text>&#x9;</xsl:text>

    <!-- isbn -->
    <!-- going to just grab the first isbn...know that's 
         an issue, we need a way to map volumes to right isbn
         see monographic series
     -->
    <xsl:for-each select="marc:datafield[@tag='020'][1]/marc:subfield[@code='a']">
      <xsl:choose>
        <xsl:when test="contains(.,' ')">
          <xsl:text>[</xsl:text>
	  <xsl:value-of select="substring-before(.,' ')" />
          <xsl:text>]</xsl:text>
	</xsl:when>
        <xsl:otherwise>
	  <xsl:text>[</xsl:text>
          <xsl:value-of select="." />
	  <xsl:text>]</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    <xsl:text>&#x9;</xsl:text>  

    <!-- series? get the 490?  Network is too flaky now to be sure-->
    <!-- need to mirror on drive www.loc.gov/marc -->

    <xsl:variable name="series">
      <xsl:for-each select="marc:datafield[@tag='490']">
        <!-- yes, 490 and $a are both repeatable -->
        <xsl:for-each select="marc:subfield[@code='a']">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="." />
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>
    <xsl:if test="$series != ''">
       <xsl:value-of select="substring($series,3)" />
    </xsl:if>
    <xsl:text>&#x9;</xsl:text>  

    <!-- source -->
    <!-- attempting to use the 040 here, might
         be better to use something else, like the holding
         institution.  seems like from LT though it's where
         the metadata is coming from
      -->
    <!-- ok, so there's a bit of an annoying tree of 
         decisions.  I'm going to go in the following order...
         get the rightmost $d if it exists, otherwise get $a 
         -->
    <xsl:if test="marc:datafield[@tag='040']">
      <xsl:choose>
        <xsl:when test="marc:datafield[@tag='040']/marc:subfield[@code='d']">
           <xsl:for-each select="marc:datafield[@tag='040']/marc:subfield[@code='d'][position() = last()]">
             <xsl:value-of select="." />
           </xsl:for-each>
        </xsl:when>
        <xsl:when test="marc:datafield[@tag='040']/marc:subfield[@code='a']">
           <xsl:value-of select="marc:datafield[@tag='040']/marc:subfield[@code='a']" />
        </xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:text>&#x9;</xsl:text>

    <!-- 
	 we'll need a lookup table for the languages 
	 ultimately, for now just going to get the language code 
         for the first version.  Also ignoring subfields $d & $e
	 for now, cause...well, just because.
      -->

    <!-- language 1 -->
    <!--
	ok, so for some reason the output has it as (blank) 
	instead of null, thus making this a lot uglier than
	it has to be

	
      -->
    <xsl:choose>
      <xsl:when test="marc:datafield[@tag='041'][1]/marc:subfield[@code='a'][1]">
	<xsl:value-of select="marc:datafield[@tag='041'][1]/marc:subfield[@code='a'][1]" />
      </xsl:when>
      <xsl:otherwise>
	<!-- going to assume English, should use 
	     the country of origin or something fancier to guess-->
	<xsl:text>English</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#x9;</xsl:text>

    <!-- language 2 -->
    <!-- like everything, there could be really weird marc
	 that does soemthing like have two 041 fields -->

    <!-- seems like I should be able to get the 
	 set of all marc:datafield[@tag='041']/marc:subfield[@code='a']
	 and get the second one...but this comes to me off the top of
	 my head
      -->
    <xsl:choose>
      <xsl:when test="marc:datafield[@tag='041'][1]/marc:subfield[@code='a'][2]">
	<xsl:value-of select="marc:datafield[@tag='041'][1]/marc:subfield[@code='a'][2]" />
      </xsl:when>
      <xsl:when test="marc:datafield[@tag='041'][2]/marc:subfield[@code='a'][1]">
	<xsl:value-of select="marc:datafield[@tag='041'][2]/marc:subfield[@code='a'][1]" />
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>(blank)</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#x9;</xsl:text>

    <!-- original language -->
    <xsl:choose>
      <xsl:when test="marc:datafield[@tag='041']/marc:subfield[@code='h'][1]">
	<xsl:value-of select="marc:datafield[@tag='041']/marc:subfield[@code='h'][1]" />
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>(blank)</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#x9;</xsl:text>

    <!-- LCC -->
    <!-- guesing they mean library of congress classification, not
	 library of congress control number.
      -->
    <xsl:variable name="lcc">
      <xsl:text>, </xsl:text>
      <xsl:for-each select="marc:datafield[@tag='050']">
	<xsl:apply-templates mode="LCC" select="." />
      </xsl:for-each>
    </xsl:variable>

    <xsl:value-of select="substring($lcc,3)" />
    <xsl:text>&#x9;</xsl:text>

    <!-- DCC -->
    <xsl:variable name="dcc">
      <xsl:text>, </xsl:text>
      <xsl:for-each select="marc:datafield[@tag='082']">
	<xsl:apply-templates mode="DCC" select="." />
      </xsl:for-each>
    </xsl:variable>

    <xsl:value-of select="substring($dcc,3)" />
    <xsl:text>&#x9;</xsl:text>


    <!-- BCID don't think MARC supports this without using a local field -->
    <xsl:text>&#x9;</xsl:text>

    <!-- date entered -->
    <!-- 
	 this appears four times in the spreadsheet
	 not sure why
      -->
    <xsl:choose>
      <xsl:when test="marc:controlfield[@tag='005']">
	<!-- need to transform this -->
	<xsl:value-of select="substring(marc:controlfield[@tag='005'],1,8)" />
      </xsl:when>
      <!-- where else could this information be hiding? -->
    </xsl:choose>

    <!-- date entered -->
    <xsl:text>&#x9;</xsl:text>

    <!-- date entered -->
    <xsl:text>&#x9;</xsl:text>

    <!-- date entered -->
    <xsl:text>&#x9;</xsl:text>

    <!-- stars -->
    <xsl:text>&#x9;</xsl:text>

    <!-- review -->
    <xsl:text>&#x9;</xsl:text>
    
    <!-- summary -->
    <xsl:text>&#x9;</xsl:text>

    <!-- comments -->
    <xsl:text>&#x9;</xsl:text>

    <!-- private comments -->
    <xsl:text>&#x9;</xsl:text>

    <!-- your copies -->
    <xsl:text>&#x9;</xsl:text>

    <!-- encoding -->
    <!-- 
	 what does encoding mean here? Of the book? Of the record? huh?
	 the document I have downloaded said "ASCII" for each row,
	 but the document itself is in UTF16 and I have no clue
	 what the records are in
      -->
    <xsl:text>UTF8</xsl:text>
    <xsl:text>&#x9;</xsl:text>

     <xsl:text>&#xa;</xsl:text>
  </xsl:template>

<!-- reverse name, really putting the name in the normal order -->
<!-- needs to be more complicated -->
  <xsl:template name="reverseName">
    <xsl:param name="name" />
<!--

<xsl:value-of select="concat(substring-before(substring-after(marc:datafield[@tag='100']/marc:subfield[@code='a'],', '),'.'),' ',substring-before(marc:datafield[@tag='100']/marc:subfield[@code='a'],', '))" />
--> 
<xsl:value-of select="concat(substring-before(substring-after($name,', '),'.'),' ',substring-before($name,', '))" />

 </xsl:template>


  <!-- as always, I never know if I want to be 
       more visible by default or less visible
       going with less

       in some ways I probably should always cover the
       case if there's a datafield but no subfields
    -->

  <xsl:template match="*" mode="LCC">
    <xsl:apply-templates select="*" mode="LCC"/>
  </xsl:template>

  <xsl:template match="text()" mode="LCC" />

  <xsl:template match="marc:subfield" mode="LCC">
    <xsl:if test="@code='a' or @code='b' or @code='3'">
      <xsl:value-of select="." />
    </xsl:if>
  </xsl:template>

  <xsl:template match="*" mode="DCC">
    <xsl:apply-templates select="*" mode="DCC"/>
  </xsl:template>

  <xsl:template match="text()" mode="DCC" />

  <xsl:template match="marc:subfield" mode="DCC">
    <xsl:if test="@code='a' or  @code='b' or @code='2'">
      <xsl:value-of select="." />
    </xsl:if>
  </xsl:template>

 


  <xsl:template name="extractPages">
    <xsl:param name="chunk" />
  
    <!-- if it contains a comma or space get everything after that.  Otherwise
         we're done and return what's in chunk -->
    <xsl:choose>
       <xsl:when test="contains(normalize-space($chunk),' ')">
         <xsl:call-template name="extractPages">
           <xsl:with-param name="chunk" select="substring-after(normalize-space($chunk),' ')" />
         </xsl:call-template> 
       </xsl:when>
       <xsl:when test="contains(normalize-space($chunk),',')">
         <xsl:call-template name="extractPages">
           <xsl:with-param name="chunk" select="substring-after(normalize-space($chunk),',')" />
         </xsl:call-template>
       </xsl:when>
       <xsl:otherwise>
         <xsl:value-of select="$chunk" />
      </xsl:otherwise>
    </xsl:choose> 
  </xsl:template>

</xsl:stylesheet>
