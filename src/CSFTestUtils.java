
import java.io.*;
import java.net.URLConnection;

public class CSFTestUtils
{

    public CSFTestUtils()
    {
    }

    public static String getFileContents(String fileName)
        throws IOException
    {
        InputStream is = CSFTestUtils.class.getResourceAsStream("/input/" + fileName);
        return getStringFromInStream(is);
    }

    public static String getURLResponse(URLConnection urlConn)
        throws IOException
    {
        InputStream is = urlConn.getInputStream();
        return getStringFromInStream(is);
    }

    private static String getStringFromInStream(InputStream is)
        throws IOException
    {
        BufferedReader br = new BufferedReader(new InputStreamReader(is));
        StringBuffer sb = new StringBuffer();
        for(String nextLine = null; (nextLine = br.readLine()) != null;)
        {
            sb.append(nextLine);
            sb.append("\n");
        }

        return sb.toString();
    }

    public static void WriteToFile(String outFileName, String output)
        throws Exception
    {
        FileWriter fw = new FileWriter("output/" + outFileName);
        fw.write(output);
        fw.close();
    }

    public static void logMessage(String message)
    {
        System.out.println(message);
    }
}