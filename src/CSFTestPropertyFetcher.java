


/*
 * Source : PropertyFetcher.java
 *
 *  Changes log
 * --------------------------------------------------------------------------------------
 * Sr No | Description              |   Date   |     By      | Version No. |  Remarks  |.
 * --------------------------------------------------------------------------------------
 *   1     Created                         21/04/04          Pankaj          1.0
 *   2     Coding Standards Applied   21/04/04     Vishal              2.0
 *   3     Modified for                             11/10/04     Raghu           3.0
 *                   multiversioning
 *   4     removed sysouts            01/12/05     Joseph          4.0
 *   5     Implemented CCN 1066        15/09/2006   Josepha                    Removed prepending of
 *                                                                                                                                                          "config" from paths.
 */
import java.util.MissingResourceException;
import java.util.ResourceBundle;


/**
 * Title: PropertyFetcher
 * Description: This is a utility class used to fetch application specific
 * property values from property
 * Copyright: Copyright (c) 2004
 * Company: Mastek Limited.
 * @author Pankaj Bhogte and Vishal Kamath
 * @version 2.0
 */
public class CSFTestPropertyFetcher
 {
   public static final String RESOURCE_BUNDLE_FILE_NAME = "CSFTestProperties";
    public static ResourceBundle resourceBundle = ResourceBundle.getBundle(RESOURCE_BUNDLE_FILE_NAME);;
  
  
    public static String getValueForKey(String key)  throws Exception
     {
        try
         {
            String fetchedValue = resourceBundle.getString(key);

            if (fetchedValue != null)
             {
                fetchedValue = fetchedValue.trim();
            }

            return fetchedValue;
        } catch (MissingResourceException mre)
         {
            //throw (Exception) ExceptionFactory.createException(Constants.MessageCode.MISSING_PROPERTY_EXCEPTION_CODE,mre);
        	 System.out.println("missing resource exception" + mre);
        }catch (Exception mre)
         {
            //throw (Exception) ExceptionFactory.createException(Constants.MessageCode.MISSING_PROPERTY_EXCEPTION_CODE,mre);
        	 System.out.println("Exception" + mre);
        }

        return null;
    }

}
