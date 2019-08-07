# Serializable VFP object to XML

Serializable VFP object to XML Very simple, no help Using: Where? Anywhere in your program. What time? If your program can be crash and you need save object with properties and values. 

## VFP Compatibility
VFP 8, VFP 9, VFP Advanced, VFP Advanced 64 bit

## Files
serializableobject.PRG - main program


## Examples

### Example 1 
```foxpro
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
```

### Example 2 
```foxpro
LOCAL m.lcPath, m.loSO, m.lcFile, m.loXX, m.lcAlias
m.lcPath=JUSTPATH(SYS(16))+"\"

SET PROCEDURE TO (m.lcPath+"..\src\serializableobject.prg")

m.loSO=CREATEOBJECT("_SerializableObject2XML")
m.loSO.lShowChangedProperties=.T. 

m.lcAlias=SYS(2015)
CREATE CURSOR (m.lcAlias) (XX000 M, XX001 W)
INSERT INTO (m.lcAlias) (XX000, XX001) VALUES (REPLICATE("A", 256), 0h+REPLICATE("A", 256))

m.loXX=CREATEOBJECT("Empty")
=ADDPROPERTY(m.loXX, "P1_C", "Hello")
=ADDPROPERTY(m.loXX, "P2_C_BC", "Hello"+CHR(9)+"kitty.")
=ADDPROPERTY(m.loXX, "P14_V", CAST("Hello" AS V(5)))
=ADDPROPERTY(m.loXX, "P3_M", XX000)
=ADDPROPERTY(m.loXX, "P4_W", XX001)
=ADDPROPERTY(m.loXX, "P5_Q", 0h+REPLICATE('A',256))
=ADDPROPERTY(m.loXX, "P6_L", .F.)
=ADDPROPERTY(m.loXX, "P7_D", DATE())
=ADDPROPERTY(m.loXX, "P8_T", DATETIME())
=ADDPROPERTY(m.loXX, "P9_I", CAST(1 AS INT))
=ADDPROPERTY(m.loXX, "P10_N", 1.1)
=ADDPROPERTY(m.loXX, "P11_B", CAST(1.2 AS DOUBLE))
=ADDPROPERTY(m.loXX, "P12_Y", CAST(1.3 AS CURRENCY))
=ADDPROPERTY(m.loXX, "P13_F", CAST(1.4 AS FLOAT))


m.lcFile=SYS(2023)+"\MyFile.xml"
m.lcFile=m.loSO.Serializable(m.loXX, m.lcFile)

IF !EMPTY(m.lcFile)
   MODIFY FILE (m.lcFile) 
   DELETE FILE (m.lcFile)
ENDIF
USE IN (m.lcAlias)

SET PROCEDURE TO 
```
