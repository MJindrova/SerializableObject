
*!*	Serializable object to XML

*!*	Author:  Martina Jindrová
*!*	E-mail:  jindra@egservis.cz
*!*	JID:     gorila@dione.zcu.cz  
*!*	Date:    21.07.2010

*!*	Version: 0.0.6
*!*	Changes: Date, datetime, number  - XML format
*!*	Date:    24.07.2011

*!*	Version: 0.0.4
*!*	Changes: m dot fix
*!*	Date:    13.02.2011

*!*	Version: 0.0.3
*!*	Changes: Add new property lShowChangedProperties. If value is .T. then only changed properties wiil be save to XML

DEFINE CLASS _SerializableObject2XML AS CUSTOM
   Name="_SerializableObject2XML"

   PROTECTED iLevel, cBadChars, iObjectList
   PROTECTED ARRAY aObjectList(1) && list of objects

   iLevel=-1     && The object hierarchy level
   iObjectList=0 && Count of items in object list
   iFile=-1      && File handle

   lShowChangedProperties=.F. && Show Changed Properties

   cBadChars="" && list of bad XML characters


   PROCEDURE Init
      *
      * _SerializableObject2XML::Init
      *
      
      LOCAL m.lcBadChars
      m.lcBadChars=""
      FOR m.lii=0 TO 31
          m.lcBadChars=m.lcBadChars+CHR(m.lii)
      NEXT
      This.cBadChars=m.lcBadChars
   ENDPROC


   PROCEDURE StrTranHTMLString
      *
      * _SerializableObject2XML::StrTranHTMLString
      *
      LPARAMETERS m.lcString
      
      * lcString 
      RETURN STRTRAN(STRTRAN(STRTRAN(STRTRAN(m.lcString, "&", "&amp;"), ">", "&gt;"), "<", "&lt;"), '"', "&quot;")
   ENDPROC


   PROTECTED PROCEDURE AddObject2List
      *
      * _SerializableObject2XML::AddObject2List
      *
      LPARAMETERS m.loObj
      
      LOCAL m.llExist
      m.llExist=PEMSTATUS(m.loObj, "__SerializableObjectID", 5)
      IF NOT m.llExist
         This.iObjectList=This.iObjectList+1
         DIME This.aObjectList(This.iObjectList)
         This.aObjectList(This.iObjectList)=m.loObj
         =ADDPROPERTY(m.loObj, "__SerializableObjectID", SYS(2015))
      ENDIF
      RETURN m.llExist
   ENDPROC


   PROTECTED PROCEDURE FreeObjectList
      *
      * _SerializableObject2XML::FreeObjectList
      *

      LOCAL m.lii
      FOR m.lii=1 TO This.iObjectList
         =REMOVEPROPERTY(This.aObjectList(m.lii), "__SerializableObjectID")
      NEXT
      STORE .NULL. TO This.aObjectList
      This.iObjectList=0
      DIME This.aObjectList(1)
   ENDPROC


   PROCEDURE Serializable && Convert object to XML
      *
      * _SerializableObject2XML::Serializable
      *
      LPARAMETERS m.luValue, m.lcFile
      
      * luValue - Object reference
      * lcFile  - Output file name
      IF EMPTY(m.lcFile)
         m.lcFile=SYS(2023)+"\"+SYS(2015)+".xml"
      ENDIF   
      This.iFile=FCREATE(m.lcFile,0)
      IF This.iFile<=0
         RETURN ""
      ENDIF

      TEXT TO m.lcData TEXTMERGE NOSHOW
<?xml version="1.0" encoding="windows-<<CPCURRENT()>>" standalone="yes"?>
<result>

      ENDTEXT
      =FWRITE(This.iFile, m.lcData)

      This.ToXML(m.luValue) && Convert object to XML

      TEXT TO lcData TEXTMERGE NOSHOW 
</result>

      ENDTEXT
      =FWRITE(This.iFile, m.lcData)
      =FCLOSE(This.iFile)
      This.iFile=-1
      This.FreeObjectList()
      RETURN m.lcFile
   ENDPROC


   PROTECTED PROCEDURE ToXML && Convert object to XML
      *
      * _SerializableObject2XML::ToXML
      *
      LPARAMETERS m.luValue

      * luValue - Object reference
      LOCAL m.lcType, m.lii, m.liy, m.liz, m.loObj, m.lcPom, m.liRows, m.liCols, m.lcpom2, m.lcName, m.lcTABs,;
            m.lcValue, m.lcPEM, m.luMember, m.lix, m.llExist, m.luItem, m.llObj
      LOCAL ARRAY m.laMembers(1)  

      This.iLevel=This.iLevel+1
      m.lcTABs=SPACE(This.iLevel)

      m.lcType=VARTYPE(m.luValue)  && Typ ofpassed value
      IF m.lcType#'O' OR ISNULL(m.luValue)
         m.lcValue=IIF(m.lcType="W" OR m.lcType="Q",STRCONV(m.luValue, 13),;
                   IIF((m.lcType="C" OR m.lcType="M" OR m.lcType="V") AND LEN(CHRTRAN(m.luValue, This.cBadChars, ""))<>LEN(m.luValue), STRCONV(m.luValue, 13),;
                   IIF(m.lcType="C" OR m.lcType="M" OR m.lcType="V", This.StrTranHTMLString(m.luValue),;
                   IIF(m.lcType="I" OR m.lcType="B" OR m.lcType="N" OR m.lcType="F", CHRTRAN(TRANSFORM(m.luValue), SET("POINT"), "."),;
                   IIF(m.lcType="Y", CHRTRAN(TRANSFORM(MTON(m.luValue)), SET("POINT"), "."),;
                   IIF(m.lcType="D", LEFT(TTOC(m.luValue, 3), 10),;
                   IIF(m.lcType="T", TTOC(m.luValue, 3), m.luValue)))))))


         TEXT TO m.lcData TEXTMERGE NOSHOW
<<m.lcTABs>><value type="<<m.lcType>>"><<m.lcValue>></value>

         ENDTEXT
         =FWRITE(This.iFile, m.lcData)
         This.iLevel=This.iLevel-1
         RETURN ""
      ENDIF

      
      IF PEMSTATUS(m.luValue, "BaseClass",5 ) AND UPPER(m.luValue.BaseClass)=='COLLECTION'
         TEXT TO m.lcData TEXTMERGE NOSHOW
<<m.lcTABs>><collection>

         ENDTEXT
         =FWRITE(This.iFile, m.lcData)
         FOR m.liz=1 TO luValue.Count
             m.luItem=luValue.Item(m.liz)

             m.llObj=VARTYPE(m.luItem)="O"   
             m.llExist=IIF(m.llObj, This.AddObject2List(m.luItem) ,.F.)

             IF m.llObj
                IF TYPE("m.luItem.Name")="C"
                   TEXT TO m.lcData TEXTMERGE NOSHOW
<<m.lcTABs>><object name="<<m.luItem.Name>>">

                   ENDTEXT
                ELSE
                   TEXT TO lcData TEXTMERGE NOSHOW
<<m.lcTABs>><object name="">

                   ENDTEXT
                ENDIF   
                =FWRITE(This.iFile, m.lcData)
             ENDIF   
             IF NOT m.llExist
                This.ToXML(m.luItem)
             ELSE
                TEXT TO m.lcData TEXTMERGE NOSHOW 
<<m.lcTABs>><linkedobject name="<<m.luItem.__SerializableObjectID>>" />

                ENDTEXT
                =FWRITE(This.iFile, m.lcData)
             ENDIF
             IF m.llObj
                TEXT TO m.lcData TEXTMERGE NOSHOW
<<m.lcTABs>></object>

                ENDTEXT
                =FWRITE(This.iFile, m.lcData)
             ENDIF   
         NEXT
         TEXT TO m.lcData TEXTMERGE NOSHOW
<<m.lcTABs>></collection>

         ENDTEXT
         =FWRITE(This.iFile, m.lcData)
      ENDIF 

      * walk member list
      m.liy=AMEMBERS(m.laMembers, m.luValue) 
      FOR m.lii=1 TO m.liy
          m.lcPEM=m.laMembers(m.lii)

          TRY
            m.lcType=IIF(TYPE("ALEN(m.luValue."+m.lcPEM+")")="N", "A", TYPE('EVAL("m.luValue."+m.lcPEM)'))
          CATCH 
            m.lcType="U"
          ENDTRY  

          DO CASE
             CASE m.lcPEM=='OBJECTS'
                  TEXT TO m.lcData TEXTMERGE NOSHOW
<<m.lcTABs>><collection name="<<m.lcPEM>>" />

                  ENDTEXT
                  =FWRITE(This.iFile, m.lcData)

             CASE m.lcPEM=='CONTROLS'
                  TEXT TO lcData TEXTMERGE NOSHOW
<<m.lcTABs>><collection name="<<m.lcPEM>>" />

                  ENDTEXT
                  =FWRITE(This.iFile, m.lcData)
                  FOR m.liz=1 TO m.luValue.ControlCount
                      m.llExist=This.AddObject2List(m.luValue.Controls(m.liz))

                      IF TYPE("m.luValue.Controls(m.liz).Name")="C"
                         TEXT TO m.lcData TEXTMERGE NOSHOW
<<m.lcTABs>><object name="<<m.luValue.Controls(m.liz).Name>>">

                         ENDTEXT
                      ELSE
                         TEXT TO m.lcData TEXTMERGE NOSHOW
<<m.lcTABs>><object name="">

                         ENDTEXT
                      ENDIF   
                      =FWRITE(This.iFile, m.lcData)
                      IF NOT m.llExist
                         This.ToXML(m.luValue.Controls(m.liz))
                      ELSE
                         TEXT TO m.lcData TEXTMERGE NOSHOW 
<<m.lcTABs>><linkedobject name="<<m.luValue.Controls(m.liz).__SerializableObjectID>>" />

                         ENDTEXT
                         =FWRITE(This.iFile, m.lcData)
                      ENDIF
                      TEXT TO m.lcData TEXTMERGE NOSHOW
<<m.lcTABs>></object>

                      ENDTEXT
                      =FWRITE(This.iFile,m.lcData)
                  NEXT

             CASE m.lcPEM=='PAGES'
                  TEXT TO m.lcData TEXTMERGE NOSHOW 
<<m.lcTABs>><collection name="<<m.lcPEM>>" />

                  ENDTEXT
                  =FWRITE(This.iFile, m.lcData)
                  FOR m.liz=1 TO m.luValue.PageCount
                      m.llExist=This.AddObject2List(m.luValue.Pages(m.liz))

                      TEXT TO m.lcData TEXTMERGE NOSHOW 
<<m.lcTABs>><object name="<<m.luValue.Pages(m.liz).Name>>">

                      ENDTEXT
                      =FWRITE(This.iFile, m.lcData)
                      IF NOT m.llExist
                         This.ToXML(m.luValue.Pages(m.liz))
                      ELSE
                         TEXT TO m.lcData TEXTMERGE NOSHOW 
<<m.lcTABs>><linkedobject name="<<m.luValue.Pages(m.liz).__SerializableObjectID>>" />

                         ENDTEXT
                         =FWRITE(This.iFile, m.lcData)
                      ENDIF
                      TEXT TO m.lcData TEXTMERGE NOSHOW 
<<m.lcTABs>></object>

                      ENDTEXT
                      =FWRITE(This.iFile, m.lcData)
                  NEXT

             CASE m.lcPEM=='COLUMNS'
                  TEXT TO m.lcData TEXTMERGE NOSHOW 
<<m.lcTABs>><collection name="<<m.lcPEM>>" />
                  ENDTEXT
                  =FWRITE(This.iFile, m.lcData)
                  FOR m.liz=1 TO m.luValue.ColumnCount
                      m.llExist=This.AddObject2List(m.luValue.Columns(m.liz))

                      TEXT TO m.lcData TEXTMERGE NOSHOW 
<<m.lcTABs>><object name="<<m.luValue.Columns(m.liz).Name>>">
                      ENDTEXT
                      =FWRITE(This.iFile, m.lcData)
                      IF NOT m.llExist
                         This.ToXML(m.luValue.Columns(m.liz))
                      ELSE
                         TEXT TO m.lcData TEXTMERGE NOSHOW 
<<m.lcTABs>><linkedobject name="<<m.luValue.Columns(m.liz).__SerializableObjectID>>" />

                         ENDTEXT
                         =FWRITE(This.iFile, m.lcData)
                      ENDIF
                         
                      TEXT TO m.lcData TEXTMERGE NOSHOW 
<<m.lcTABs>></object>

                      ENDTEXT
                      =FWRITE(This.iFile, m.lcData)
                  NEXT


             CASE m.lcPEM=='ACTIVEFORM' OR m.lcPEM=='ACTIVECONTROL' OR m.lcPEM=='PARENT'
                  TEXT TO m.lcData TEXTMERGE NOSHOW 
<<m.lcTABs>><object name="<<m.lcPEM>>"><<IIF(TYPE('m.luValue.'+m.lcPEM)<>'O','',EVAL('m.luValue.'+m.lcPEM+'.Name'))>></object>

                  ENDTEXT
                  =FWRITE(This.iFile, m.lcData)

             CASE m.lcType="A"
                  m.lcPom='luValue.'+m.lcPEM
                  m.liRows=EVAL("ALEN("+m.lcPom+", 1)")
                  m.liCols=EVAL("ALEN("+m.lcPom+", 2)")
                  IF m.liCols>0
                     TEXT TO m.lcData TEXTMERGE NOSHOW 
<<m.lcTABs>><array name="<<m.lcPEM>>" rows="<<m.liRows>>" cols="<<m.liCols>>">

                     ENDTEXT
                  ELSE
                     TEXT TO m.lcData TEXTMERGE NOSHOW 
<<m.lcTABs>><array name="<<m.lcPEM>>" rows="<<m.liRows>>">

                     ENDTEXT
                  ENDIF
                  =FWRITE(This.iFile, m.lcData)

                  * walk cells
                  FOR m.liz=1 TO EVAL("ALEN("+m.lcPom+")")
                      IF m.liCols>0
                         m.liRow=INT((m.liz-1)/m.liCols)+1
                         m.liCol=m.liz-((m.liRow-1)*m.liCols)
                         
                         TEXT TO m.lcData TEXTMERGE NOSHOW 
<<m.lcTABs>><cell row="<<m.liRow>>" col="<<m.liCol>>">

                         ENDTEXT
                      ELSE
                         TEXT TO m.lcData TEXTMERGE NOSHOW 
<<m.lcTABs>><cell row="<<m.liz>>">

                         ENDTEXT
                      ENDIF   
                      =FWRITE(This.iFile, m.lcData)
                      This.ToXML(EVAL(m.lcPom+"(m.liz)"))
                      TEXT TO lcData TEXTMERGE NOSHOW
<<m.lcTABs>></cell>

                      ENDTEXT
                      =FWRITE(This.iFile, m.lcData)
                  NEXT
                                    
                  TEXT TO m.lcData TEXTMERGE NOSHOW
<<m.lcTABs>></array>

                  ENDTEXT
                  =FWRITE(This.iFile,m.lcData)

             CASE m.lcPEM=='LIST'
                  m.lcPom='m.luValue.'+m.lcPEM
                  m.liRows=m.luValue.ListCount
                  m.liCols=m.luValue.ColumnCount
                  TEXT TO m.lcData TEXTMERGE NOSHOW 
<<m.lcTABs>><list rows="<<m.liRows>>" cols="<<m.liCols>>">

                  ENDTEXT
                  =FWRITE(This.iFile, m.lcData)

                  FOR m.liRow=1 TO m.liRows
                      TEXT TO m.lcData TEXTMERGE NOSHOW 
<<m.lcTABs>><listrow row="<<m.liRow>>">

                      ENDTEXT
                      =FWRITE(This.iFile, m.lcData)
                      FOR m.liCol=1 TO m.liCols
                          TEXT TO m.lcData TEXTMERGE NOSHOW 
<<m.lcTABs>><listcol col="<<m.liCol>>">

                          ENDTEXT
                          =FWRITE(This.iFile, m.lcData)

                          This.ToXML(m.luValue.List(m.liRow, m.liCol))
                          TEXT TO m.lcData TEXTMERGE NOSHOW
<<m.lcTABs>></listcol>

                          ENDTEXT
                          =FWRITE(This.iFile, m.lcData)
                      NEXT   

                      TEXT TO m.lcData TEXTMERGE NOSHOW
<<m.lcTABs>></listrow>

                      ENDTEXT
                      =FWRITE(This.iFile, m.lcData)
                  NEXT
                                    
                  TEXT TO m.lcData TEXTMERGE NOSHOW
<<m.lcTABs>></list>

                  ENDTEXT
                  =FWRITE(This.iFile, m.lcData)
   

             CASE m.lcType='O'
                  m.loObj=EVAL("m.luValue."+m.lcPEM)
                  TEXT TO m.lcData TEXTMERGE NOSHOW 
<<m.lcTABs>><object name="<<m.lcPEM>>">

                  ENDTEXT
                  =FWRITE(This.iFile, m.lcData)

                  IF !ISNULL(m.loObj)  && pokud ona vlastnost je nenulová
                     m.llExist=This.AddObject2List(m.loObj)
                     IF NOT m.llExist
                        * pak pøidej názae nalinkovaného objektu
                        This.ToXML(m.loObj)
                     ELSE
                        TEXT TO m.lcData TEXTMERGE NOSHOW 
<<m.lcTABs>><linkedobject name="<<m.loObj.__SerializableObjectID>>" />

                        ENDTEXT
                        =FWRITE(This.iFile, m.lcData)
                     ENDIF
                  ENDIF   
                  TEXT TO m.lcData TEXTMERGE NOSHOW 
<<m.lcTABs>></object>

                  ENDTEXT
                  =FWRITE(This.iFile, m.lcData)

             OTHERWISE

                  DO CASE
                     CASE m.lcType==""
                          m.lcPom= This.StrTranHTMLString("Damaged property")
                          TEXT TO m.lcData TEXTMERGE NOSHOW
<<m.lcTABs>><value type="<<m.lcType>>" flag="DP" name="<<m.lcPEM>>"><<m.lcPom>></value>

                          ENDTEXT
                          =FWRITE(This.iFile, m.lcData)
                          
                     CASE m.lcType="U"
                          m.lcPom= This.StrTranHTMLString("Hidden or Protected property")
                          TEXT TO m.lcData TEXTMERGE NOSHOW
<<m.lcTABs>><value type="<<m.lcType>>" flag="HPP" name="<<m.lcPEM>>"><<m.lcPom>></value>

                          ENDTEXT
                          =FWRITE(This.iFile, m.lcData)
                     
                     OTHERWISE
                          m.luMember=EVAL("m.luValue."+m.lcPEM)
                          IF NOT This.lShowChangedProperties OR This.lShowChangedProperties AND PEMSTATUS(m.luValue, m.lcPEM, 0)
                             m.lcValue=IIF(m.lcType="W" OR m.lcType="Q", STRCONV(m.luMember, 13),;
                                       IIF((m.lcType="C" OR m.lcType="M" OR m.lcType="V") AND LEN(CHRTRAN(m.luMember, This.cBadChars, ""))<>LEN(m.luMember), STRCONV(m.luMember, 13),;
                                       IIF(m.lcType="C" OR m.lcType="M" OR m.lcType="V", This.StrTranHTMLString(m.luMember),;
                                       IIF(m.lcType="I" OR m.lcType="B" OR m.lcType="N" OR m.lcType="F", CHRTRAN(TRANSFORM(m.luMember),SET("POINT"),"."),;
                                       IIF(m.lcType="Y", CHRTRAN(TRANSFORM(MTON(m.luMember)), SET("POINT"), "."),;
                                       IIF(m.lcType="D", LEFT(TTOC(m.luMember, 3), 10),;
                                       IIF(m.lcType="T", TTOC(m.luMember, 3), m.luMember)))))))



                             TEXT TO m.lcData TEXTMERGE NOSHOW 
<<m.lcTABs>><value type="<<m.lcType>>" name="<<m.lcPEM>>"><<m.lcValue>></value>

                             ENDTEXT
                             =FWRITE(This.iFile, m.lcData)
                          ENDIF   
                  ENDCASE
          ENDCASE

      NEXT
      This.iLevel=This.iLevel-1
      RETURN ""
   ENDPROC

ENDDEFINE





*!*	W, Blob - - Blob 
*!*	Q, Varbinary n - Varbinary field of width n

*!*	C, Char, Character n – Character field of width n
*!*	M, Memo – – Memo 
*!*	V, Varchar n - Varchar field of width n

*!*	Y, Currency – – Currency 
*!*	I, Int, Integer – – Integer 
*!*	B, Double – d Double 
*!*	N, Num, Numeric n d Numeric field of width n with d decimal places
*!*	F, Float n d Floating Numeric field of width n with d decimal places

*!*	D, Date – – Date 
*!*	T, DateTime – – DateTime 

*!*	G, General – – General 

*!*	L, Logical – – Logical 

