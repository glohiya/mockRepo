package com.test;

import java.io.*;
import java.sql.*;
import java.util.*;

/**
 * Example of how to query a database using JDBC.
 * 
 * <p>
 * The program demonstrates
 * </p>
 * <ul>
 * <li>Use of properties to hold JDBC driver and database details</li>
 * <li>Use of the SQL command SELECT</li>
 * <li>Processing of ResultSet objects</li>
 * </ul>
 * 
 * @author Karim Djemame and Nick Efford
 * @version 2.0 [2007-09-03]
 */

public class QueryDB {

	public static final String propsFile = "jdbc.properties";

	/**
	 * Establishes a connection to the database.
	 * 
	 * @return Connection object representing the connection
	 * @throws IOException
	 *             if properties file cannot be accessed
	 * @throws SQLException
	 *             if connection fails
	 */

	public static Connection getConnection() throws IOException, SQLException {
		// Load properties

		FileInputStream in = new FileInputStream(propsFile);
		Properties props = new Properties();
		props.load(in);

		// Define JDBC driver

		String drivers = props.getProperty("jdbc.drivers");
		if (drivers != null)
			System.setProperty("jdbc.drivers", drivers);
		// Setting standard system property jdbc.drivers
		// is an alternative to loading the driver manually
		// by calling Class.forName()

		// Obtain access parameters and use them to create connection

		String url = props.getProperty("jdbc.url");
		String user = props.getProperty("jdbc.user");
		String password = props.getProperty("jdbc.password");

		return DriverManager.getConnection(url, user, password);
	}

	/**
	 * Queries the database to find student names.
	 * 
	 * @param forename
	 *            forename to search for in database
	 * @param database
	 *            connection to database
	 * @throws SQLException
	 *             if query fails
	 */

	public static void findNames(String forename, Connection database)
			throws SQLException {
		Statement statement = database.createStatement();
		ResultSet results = statement
				.executeQuery("SELECT * FROM students WHERE forename = '"
						+ forename + "'");
		while (results.next()) {
			String surname = results.getString("surname");
			System.out.println(forename + " " + surname);
		}
		statement.close();
	}

	/**
	 * Main program.
	 */

	public static void main(String[] argv) {
		if (argv.length == 0) {
			System.err.println("usage: java QueryDB <forename>");
			System.exit(1);
		}

		Connection connection = null;

		try {
			connection = getConnection();
			findNames(argv[0], connection);
			getCityData(argv[0], connection);
		} catch (Exception error) {
			error.printStackTrace();
		} finally {

			// This will always execute, even if an exception has
			// been thrown elsewhere in the code - so this is
			// the ideal place to close the connection to the DB...

			if (connection != null) {
				try {
					connection.close();
				} catch (Exception error) {
				}
			}
		}
	}

	private static void getCityData(String cityName, Connection connection)
			throws SQLException {
		
		Statement statement = null;
		ResultSet results = null;
		try {
			statement = connection.createStatement();
			results = statement
					.executeQuery("SELECT name, country, minTemperature, maxTemperature FROM cities WHERE name = '"
							+ cityName + "'");
			while (results.next()) {
				System.out.println(" City Name : " + cityName);
				String country = results.getString("country");
				System.out.println(" Country : " + country);
				long minTemperature = results.getLong("minTemperature");
				System.out.println(" Minimum Temperature : " + minTemperature);
				long maxTemperature = results.getLong("maxTemperature");
				System.out.println(" Maximum Temperature : " + maxTemperature);
			}
			
			results = statement
					.executeQuery("select avg(minTemperature) avgMinTemp from cities");
			while (results.next()) {
				long avgMinTemp = results.getLong("avgMinTemp");
				System.out.println(" Average Minimum Temperature : " + avgMinTemp);
			}
			
			results = statement
					.executeQuery("select avg(maxTemperature) avgMaxTemp from cities");
			while (results.next()) {
				long avgMaxTemp = results.getLong("avgMaxTemp");
				System.out.println(" Average Maximum Temperature : " + avgMaxTemp);
			}
			
		} catch (Exception ex) {
			System.out.println("Exception : "+ex);
		}
		
		
		finally {
			if(results != null)
				results.close();
			if(statement != null)
				statement.close();
		}
	}

}
