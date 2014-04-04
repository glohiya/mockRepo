package test;

public class Animal {
	Animal() {
	}

	Animal(int a) {
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		System.out.print(" animals main  ");
		final byte a;
		a = 3;
		System.out.print("\n "+a);
		char ch1 = 'g';
		boolean b5 = ch1 > 4.6;
		System.out.println("\n "+ch1+" is > 4.6 - "+b5);
		b5 = null instanceof Object;
		System.out.println("\n " + " null check= " + b5 + " " + (null instanceof Object));
		try {
			System.out.print("\n 1");
			System.out.print("\n 2");
		} catch (Exception e) {
			System.out.println("found = "+e);
		} finally {
			System.out.print("\n finally");
		}
	}
}
