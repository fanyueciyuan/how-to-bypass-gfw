##
. ./func
#Reaver_Code="${Reaver_Code} -L"
read -p "What's Your Pincode? " -e pincode                                                                                                            
print_info "Okay,${pincode} will be used."
Reaver_Code="${Reaver_Code} -p ${pincode}"
press_any_key
Crack_Main

