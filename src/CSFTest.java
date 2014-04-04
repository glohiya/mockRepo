
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;

import com.syntegra.spine.csf.channel.CSFMessageChannelImpl;
import com.syntegra.spine.csf.channel.CSFMessageChannelLocator;

public class CSFTest {
	private class MessageParams {

		public String interactionId;
		
		public String messageId;

		public String clientId;

		public String clientReference;

		MessageParams() {
			interactionId = "";
			clientId = "";
			clientReference = "";
			messageId = "";
		}
	}

	public CSFTest() {
	}

	public static void main(String args[]) throws Exception {
		String file = args[0];
		CSFTestUtils.logMessage("* Starting: " + file);
		if (!sendRequest(file)) {
			CSFTestUtils.logMessage("* ERROR: \n" + errorMessage);
			CSFTestUtils.WriteToFile(file + "_responseError.txt", "ERROR\n\n"
					+ errorMessage);
		}
		CSFTestUtils.logMessage("* End");
	}

	public static boolean sendRequest(String fileName)
	    {
	        boolean ret = true;
	        boolean syncResponseReroute = false;
	        boolean aSyncRequestReroute = false;
	        try
	        {
	            String outXML = CSFTestUtils.getFileContents(fileName);
	            MessageParams mp = getMessageParams(outXML);
	            CSFMessageChannelImpl channel = CSFMessageChannelLocator.getInstance().getChannel(mp.interactionId, mp.clientId, mp.clientReference);
	            if(validateTransport(mp.interactionId, mp.clientId, mp.clientReference, channel))
	            {
	                CSFTestUtils.logMessage("* Interaction Id: " + mp.interactionId);
	                CSFTestUtils.logMessage("* Client Id: " + mp.clientId);
	                CSFTestUtils.logMessage("* Message Id: " + mp.messageId);
	                String protocol = channel.getTransportProperty("Protocol");
	                String host = channel.getTransportProperty("Host");
	                String port = channel.getTransportProperty("Port");
	                String path = channel.getTransportProperty("Path");
	                URL uRL = new URL(protocol, host, Integer.parseInt(port), path);
	                CSFTestUtils.logMessage("* Sending To URL: " + uRL.toString());
	               	 URLConnection urlconn = uRL.openConnection();
	 	                urlconn.setRequestProperty("csfWrapperType", channel.getWrapperFormat());//channel.getWrapperFormat()
	 	                urlconn.setRequestProperty("csfResponseMode", channel.getTransportProperty("DeliveryMode"));
	 	                urlconn.setRequestProperty("interactionid", mp.interactionId);
	 	                urlconn.setRequestProperty("clientid", mp.clientId);
	 	                urlconn.setRequestProperty("messageid", mp.messageId);
	 	               //urlconn.setRequestProperty("clientid", "NPWF");
	                     aSyncRequestReroute = (new Integer(channel.getTransportProperty("DeliveryMode"))).intValue() == 1;
	 	                String responseProtocol = channel.getTransportProperty("ResponseProtocol");
	 	                String responseHost = channel.getTransportProperty("ResponseHost");
	 	                String responsePort = channel.getTransportProperty("ResponsePort");
	 	                String responsePath = channel.getTransportProperty("ResponsePath");
	 	                if(responseProtocol != null && responseHost != null && responsePort != null && responsePath != null)
	 	                {
	 	                    syncResponseReroute = true;
	 	                    urlconn.setRequestProperty("csfResponseProtocol", responseProtocol);
	 	                    urlconn.setRequestProperty("csfResponseHost", responseHost);
	 	                    urlconn.setRequestProperty("csfResponsePort", responsePort);
	 	                    urlconn.setRequestProperty("csfResponsePath", responsePath);
	 	                }
	 	                CSFTestUtils.logMessage("* Sync Response Reroute: " + syncResponseReroute);
	 	                CSFTestUtils.logMessage("* ASync Request Reroute: " + aSyncRequestReroute);
	 	                urlconn.setDoInput(true);
	 	                urlconn.setDoOutput(true);
	 	                PrintWriter out =null;
	                 out = new PrintWriter(urlconn.getOutputStream());
	                out.println(outXML);
	                out.flush();
	                CSFTestUtils.logMessage("* Request Sent Succesfully");
	                if(syncResponseReroute && aSyncRequestReroute)
	                {
	                    CSFTestUtils.logMessage("* No Response Expected (ASync Request Reroute / Sync Response Reroute)");
	                    CSFTestUtils.getURLResponse(urlconn);
	                    CSFTestUtils.WriteToFile(fileName + "_responseCode.txt", "Success\n" + ((HttpURLConnection)urlconn).getResponseCode());
	                } else
	                {
	                    String response = CSFTestUtils.getURLResponse(urlconn);
	                    CSFTestUtils.WriteToFile(fileName + "_out.xml", response);
	                    CSFTestUtils.WriteToFile(fileName + "_responseCode.txt", "Success\n" + ((HttpURLConnection)urlconn).getResponseCode());
	                    CSFTestUtils.logMessage("* Sync Response Received: Check output file");
	                }
	            } else
	            {
	                ret = false;
	            }
	        }
	        catch(Exception ex)
	        {
	            ex.printStackTrace();
	            ret = false;
	            errorMessage = ex.getMessage();
	        }
	        return ret;
	    }

	private static boolean validateTransport(String interactionId,
			String clientId, String clientReference,
			CSFMessageChannelImpl channel) {
		boolean ret = true;
		if (channel != null) {
			if (!channel.getTransportType().equals("HTTP")) {
				ret = false;
				errorMessage = "Transport Type for " + interactionId + ", "
						+ clientId + ", " + clientReference + " is not HTTP!";
			}
		} else {
			ret = false;
			errorMessage = "No channel found for " + interactionId + ", "
					+ clientId + ", " + clientReference;
		}
		return ret;
	}

	private static MessageParams getMessageParams(String message) throws Exception {
		MessageParams mp = (new CSFTest()).new MessageParams();
		String csfXMLMessage = getXMLFromString(message);
		CSFTestXMLHelper helper = new CSFTestXMLHelper(csfXMLMessage);
		mp.interactionId = helper.getNodeValue(CSFTestPropertyFetcher.getValueForKey("interactionId")); 
		mp.clientId = helper.getNodeValue(CSFTestPropertyFetcher.getValueForKey("clientId"));
		mp.messageId = helper.getNodeValue(CSFTestPropertyFetcher.getValueForKey("messageId"));
		return mp;
	}

	private static String getXMLFromString(String message) throws Exception {
		
		String startString = CSFTestPropertyFetcher.getValueForKey("startString");
		String endString = CSFTestPropertyFetcher.getValueForKey("endString");
		int start = message.indexOf(startString);
		int end = message.indexOf(endString) + endString.length();
		String xmlPart = message;
		if(start > 0 && end > 0)
			xmlPart = message.substring(start, end);
		//System.out.println(xmlPart);
		return xmlPart;
	}

	private static final String BLANK_STRING = "";

	private static String errorMessage = "";

}
