package com.test;

import java.sql.Timestamp;
import java.util.Date;
import java.util.GregorianCalendar;

enum CoffeeSize {
/// adding for fun
	TALL(12), GRANDE(16), VENTI(20) { // start a code block that defines
		// the "body" for this constant

		public String getLidCode() { // override the method
			// defined in CoffeeSize
			return "A";
		}
	}; // the semicolon is REQUIRED when more code follows

	CoffeeSize(int ounces) {
		this.ounces = ounces;
	}

	private int ounces;

	public int getOunces() {
		return ounces;
	}

	public String getLidCode() { // this method is overridden
		// by the VENTI constant

		return "B"; // the default value we want to return for
		// CoffeeSize constants
	}
}

public class CoolTests {
	
	public static final String DATE = "D";
	public static final String WEEK = "W";
	public static final String MONTH = "M";
	public static final String YEAR = "Y";
	public static final String SECOND = "S";
	
	public static Timestamp addTimestamp(Timestamp inputDate, int value, String unit)
	{
		GregorianCalendar calendar = new GregorianCalendar();
		int field = -1;
		int addValue = value;
		calendar.setTime(inputDate);
		
		if(DATE.equals(unit))
		{
			field = GregorianCalendar.DATE;
		}
		else if(WEEK.equals(unit))
		{
			field = GregorianCalendar.DATE;
			addValue = value*7;
		}
		else if(MONTH.equals(unit))
		{
			field = GregorianCalendar.MONTH;
		}
		else if(YEAR.equals(unit))
		{
			field = GregorianCalendar.YEAR;
		}
		else if(SECOND.equals(unit))
		{
			field = GregorianCalendar.SECOND;
		}
		else
		{
			//TODO Add message code
			System.out.println("Nothing");
		}
		
		calendar.add(field, addValue);
		
		return new Timestamp(calendar.getTime().getTime());
	}
	
	public static void main(String args[]) {
		String str = new String("QURX_IN000002UK02,QURX_IN000003UK02,urn:spine:interactionid:deliveryfailurenotification,urn:spine:interactionid:deliveryretrynotification,urn:spine:interactionid:deliverysuccessnotification");
		System.out.println("---------"+str.contains("PORX_IN132004UK30")+"----------");
		
		Timestamp date = new Timestamp(new Date().getTime());
		System.out.println("date = "+ date);
		System.out.println("date + 7 = " + addTimestamp(date,7, DATE));
		//code added for bug-fix of DEMO-12
		// **Added XXXX comment as per code-review**
		try{
			throw new Exception("dummy exception");
		} catch(Exception ex) {
			System.out.println(ex);
		}
	}

}

