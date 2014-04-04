
import java.io.ByteArrayInputStream;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.apache.xpath.XPathAPI;
import org.w3c.dom.*;

public class CSFTestXMLHelper
{

 public CSFTestXMLHelper(String inputXML)
     throws Exception
 {
     inputDOM = convertStringToDOM(inputXML);
 }

 private Document convertStringToDOM(String inputXML)
     throws Exception
 {
     DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
     DocumentBuilder documentBuilder = dbFactory.newDocumentBuilder();
     ByteArrayInputStream inputXMLStream = new ByteArrayInputStream(inputXML.getBytes());
     Document inputDOM = documentBuilder.parse(inputXMLStream);
     return inputDOM;
 }

 private static String trim(String string)
 {
     if(string != null)
         return string.trim();
     else
         return null;
 }

 public String getNodeValue(String XPath)
     throws Exception
 {
     Node selectedNode = XPathAPI.selectNodeList(inputDOM, XPath).item(0);
     if(selectedNode instanceof Element)
     {
         NodeList nodelist = selectedNode.getChildNodes();
         if(nodelist != null)
         {
             int listLength = nodelist.getLength();
             Node node = null;
             for(int index = 0; index < listLength; index++)
             {
                 node = nodelist.item(index);
                 if(node instanceof Text)
                     return trim(node.getNodeValue());
             }

         }
     }
     return null;
 }

 Document inputDOM;
}
