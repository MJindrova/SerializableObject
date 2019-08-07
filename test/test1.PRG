LOCAL m.lcPath, m.loSO, m.lcFile, m.loXX
m.lcPath=JUSTPATH(SYS(16))+"\"

SET PROCEDURE TO (m.lcPath+"..\src\serializableobject.prg")

m.loSO=CREATEOBJECT("_SerializableObject2XML")
*!* Method Serializable() return file which containes XML data
m.lcFile=m.loSO.Serializable(_Screen)
IF !EMPTY(m.lcFile)
   MODIFY FILE (m.lcFile) 
   DELETE FILE (m.lcFile)
ENDIF

*!* Or You can send file name to method Serializable()
m.loSO=CREATEOBJECT("_SerializableObject2XML")
m.loXX=CREATEOBJECT("Collection")
m.loForm=CREATEOBJECT("FORM")
m.loForm.AddProperty("testNULL", .NULL.)
m.loXX.Add(m.loForm, "ss")
m.loXX.Add(_Screen, "dd")
m.loXX.Add(45127, "ee")
m.lcFile=SYS(2023)+"\MyFile.xml"
m.lcFile=m.loSO.Serializable(m.loXX, m.lcFile)

IF !EMPTY(m.lcFile)
   MODIFY FILE (m.lcFile) 
   DELETE FILE (m.lcFile)
ENDIF


m.loSO=CREATEOBJECT("_SerializableObject2XML")
m.loSO.lShowChangedProperties=.T. 
m.lcFile=m.loSO.Serializable(m.loXX, m.lcFile)

IF !EMPTY(m.lcFile)
   MODIFY FILE (m.lcFile) 
   DELETE FILE (m.lcFile)
ENDIF

SET PROCEDURE TO 
