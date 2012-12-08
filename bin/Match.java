import ch.ethz.iks.slp.ServiceType;
import ch.ethz.iks.slp.ServiceURL;
import java.util.Locale;

public class Match {

public static void main(String[] args)  {
	
	try{
	ServiceType st = new ServiceType(args[1]);
	ServiceURL	su = new ServiceURL(args[0],1);
	
	
	System.out.print( su.matches(st));
	}catch(ch.ethz.iks.slp.ServiceLocationException ex) {
		System.out.print(ex.getMessage());
		}	

}

}
