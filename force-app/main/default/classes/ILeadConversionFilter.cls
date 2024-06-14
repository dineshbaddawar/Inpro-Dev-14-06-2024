/************************************************************
* Created by:   The Hunley Group
* Created on:   2/5/2020
* ===========================================================
* Test Class:   
* ===========================================================
* Purpose:     
*
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 2/5/2020       THG - Tyler    Created
*************************************************************/
public interface ILeadConversionFilter {
    List<String> getFilterValues();
    String getDefaultFilter();
}