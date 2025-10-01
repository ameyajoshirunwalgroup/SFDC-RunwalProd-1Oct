public with sharing class checkRecursion {
  
  private static boolean firstRun = true;
    private static boolean firstRunA = true;

  public static boolean isFirstRun() {
    if(firstRun) {
      firstRun = false;
      return true;
    } else {
      return firstRun;
    }
    
  }
   public static boolean isFirstRunA() {
    if(firstRunA) {
      firstRunA = false;
      return true;
    } else {
      return firstRunA;
    }
    
  }
  public static void resetFirstRun() {
    firstRun = true;
  }
      public static void resetFirstRunA() {
    firstRunA = true;
  }  
}