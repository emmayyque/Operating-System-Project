#!/bin/bash

cartTotal=0
user=""

groceryItems(){    
    currTime=$(date +"%T")
    echo "======================================"
    echo "Login as:                   $user"
    echo "Current Time:               $currTime"
    echo "======================================"
    echo "                Menu                  "
    echo "======================================"
    totalElements=${#itemList[@]}

    echo "Item No:    Items:           Prices:"
    echo "======================================"
    
    totalItems=$(wc -l < products)
    for ((i=0;i<totalItems;i++)) {
        itemName=$(sed -n "$(($i+1))p" products | cut -d" " -f1 )
        itemPrice=$(sed -n "$(($i+1))p" products | cut -d" " -f2 )
        row=($i" "$itemName" "$itemPrice"Rs")
        tableFormat $row
    }
    
}

addItems(){
    currTime=$(date +"%T")
    echo "======================================"
    echo "Login as:                   $user"
    echo "Current Time:               $currTime"
    echo "======================================"
    echo "      Add Items to Grocery List       "
    echo "======================================"
    read -p "Enter Item to Add: " item
    read -p "Enter Item Price: " price
    echo " "
    if [ -n "$item" ] && [ -n "$price" ]; then
        line=$item" "$price
        echo -e "$line" >> products        
        echo "Item added Successfully!!!"
        
    else
        echo "Item Name or Price is missing..."
    fi
    echo " "
    read -p "Press (Y) to Add Again or (N) To Return Back to Main Menu (Y/N): " proceed
    if [ $proceed == "Y" -o $proceed == "y" ]; then
        clear
        addItems
    elif [ $proceed == "N" -o $proceed == "n" ]; then
        mainMenu
    else
        clear
        addItems
    fi
}

removeItems(){
    currTime=$(date +"%T")
    echo " "
    echo "======================================"
    echo "    Remove Items from Grocery List    "
    echo "======================================"
    read -p "Enter Item No to Remove: " itemNo
    echo " "
    if [ -n "$itemNo" ]; then
        totalProducts=$(wc -l < products)
        actualItemNo=$(($itemNo+1))
        if [ $actualItemNo -le $totalProducts ]; then
            sed -i "$(($itemNo+1))d" products     
            echo "Item Removed Successfully!!!"
            read -p "" p
            clear
            groceryItems
        else
            echo "Item No is incorrect..."
        fi
    else
        echo "Item No is incorrect..."
    fi
    echo " "
    read -p "Press (Y) to Remove Again or (N) To Return Back to Main Menu (Y/N): " proceed
    if [ $proceed == "Y" -o $proceed == "y" ]; then
        clear
        groceryItems
        removeItems
    elif [ $proceed == "N" -o $proceed == "n" ]; then
        mainMenu
    else 
        clear
        groceryItems
        removeItems
    fi
}

addToCart() {
    currTime=$(date +"%T")
    echo ""
    echo "======================================"
    echo "          Add Items to Cart           "
    echo "======================================"
    read -p "Enter Item to Cart (i.e., 1,2,3): " item
    read -p "Enter Item Quantity (i.e., 1,2,3): " quantity

    itemNo=$item
    itemName=$(sed -n "$(($itemNo+1))p" products | cut -d" " -f1 )
    itemQuantity=$quantity
    if [ -n "$itemNo" ] && [ -n "$itemName" ] && [ -n "$itemQuantity" ]; then
        itemInCart=$itemNo" "$itemName" "$itemQuantity
        echo -e "$itemInCart" >> cart
        echo " " 
        echo "Item added to Cart Successfully!!!"
    else
        echo " " 
        if [ -z "$itemNo" ]; then
            echo "Please Provide Item No..."
        elif [ -z $itemName ]; then
            echo "Wrong Item No..."
        elif [ -z $itemQuantity ]; then
            echo "Please Provide Quantity..."     
        else 
            echo "You're missing something!!!"
        fi
    fi    
    echo " " 
    read -p "Press (Y) to Add Again or (N) To Return Back to Main Menu (Y/N): " proceed
    if [ $proceed == "Y" -o $proceed == "y" ]; then
        clear
        groceryItems
        addToCart
    elif [ $proceed == "N" -o $proceed == "n" ]; then
        mainMenu
    else 
        clear
        groceryItems
        addToCart
    fi
}

showCart() {
    clear
    currTime=$(date +"%T")
    echo "==================================================="
    echo "Login as:                               $user"
    echo "Current Time:                            $currTime"
    echo "==================================================="
    echo "                    Your Cart                      "
    echo "==================================================="
    
    totalItemsInCart=$(wc -l < cart)
    

    echo "Item No:    Item:            Quantity:       Price:"
    echo "==================================================="
    if [ $totalItemsInCart -eq 0 ]; then
        echo "  Your Cart is empty !!!"
        read -p "  Press Enter to continue...." proceed
    else 
        cartTotal=0
        for ((i=0;i<totalItemsInCart;i++)) {
            itemNo=$(sed -n "$(($i+1))p" cart | cut -d" " -f1 )
            itemName=$(sed -n "$(($i+1))p" cart | cut -d" " -f2 )
            itemPrice=$(sed -n $(($itemNo+1))p products | cut -d" " -f2)
            itemQuantity=$(sed -n "$(($i+1))p" cart | cut -d" " -f3 )
            totalPriceOfItem=$(($itemPrice*$itemQuantity))
            cartTotal=$(($cartTotal+$totalPriceOfItem))
            row=($itemNo" "$itemName" "$itemQuantity" "$totalPriceOfItem"Rs")
            tableFormat $row
        }
        echo "==================================================="
        echo " "
        read -p "Proceed to Checkout (Y/N): " checkout
        echo " "
        if [ $checkout == "Y" -o $checkout == "y" ]; then
            generateBill   
        elif [ $checkout == "N" -o $checkout == "n" ]; then
            mainMenu
        else 
            showCart
        fi
    fi
}

generateBill() {
    clear
    currTime=$(date +"%T")
    echo "==================================================="
    echo "Login as:                               $user"
    echo "Current Time:                            $currTime"
    echo "==================================================="
    echo "                    Your Bill                      "
    echo "==================================================="
    echo "Total Items:                                   $totalItemsInCart"
    echo "Cashier:                                $user"
    echo "Your Total Bill:                             $cartTotal"Rs""
    echo "==================================================="
    echo " "
    read -p "Do you wish to Pay (Y/N): " pay
    if [ $pay == "Y" -o $pay == "y" ]; then
        echo -n "" > cart
        row=($totalItemsInCart" "$cartTotal" "$user" "$currTime)
        echo -e "$row" >> orderHistory
        echo " "
        figlet "Thanks for Shopping Here"
        figlet "See you Again !!"
        read -p "" a
    elif [ $pay == "N" -o $pay == "n" ]; then
        mainMenu
    else 
        generateBill
    fi 
    mainMenu
}

ordersHistory(){
    clear
    currTime=$(date +"%T")
    echo "==========================================================================="
    echo "Login as:                                                       $user"
    echo "Current Time:                                                    $currTime"
    echo "==========================================================================="
    echo "                               Order History                               "
    echo "==========================================================================="
    echo "Order No:      Total Items:     Total Bill:      Username:       Order Time"
    echo "==========================================================================="
    totalOrders=$(wc -l < orderHistory)
    if [ $totalOrders -gt 0 ]; then
        for ((i=0;i<totalOrders;i++)) {
                actualOrderNo=$(($i+1))
                otItems=$(sed -n "$(($i+1))p" orderHistory | cut -d" " -f1 )
                otBill=$(sed -n "$(($i+1))p" orderHistory | cut -d" " -f2 )
                oUser=$(sed -n "$(($i+1))p" orderHistory | cut -d" " -f3)
                oTime=$(sed -n "$(($i+1))p" orderHistory | cut -d" " -f4 )
                if [ "$oUser" == "$user" ]; then
                    row=($actualOrderNo" "$otItems" "$otBill" "$oUser" "$oTime)
                    tableFormat2 $row
                fi
        }
    else 
        echo "                       You've no orders yet !!!                            "
    fi
    echo "==========================================================================="
    read -p "" p

}

tableFormat() {
    local IFS=$' '
    printf "%-11s %-16s %-15s %-5s\n" $@
}

tableFormat2() {
    local IFS=$' '
    printf "%-14s %-16s %-16s %-15s %-16s\n" $@
}

login() {
    clear
    echo ""
    echo "======================================"
    echo "             Login System             "
    echo "======================================"
    read -p "Enter your username: " username
    read -p "Enter your password: " pass
    echo " "
    userNameFromFile=$(grep -r "$username" users | cut -d" " -f2)
    passFromFile=$(grep -r "$username" users| cut -d" " -f3)
    if [ -n "$username" ] && [ -n "$pass" ]; then
        if [ "$userNameFromFile" == "$username" ]; then
            if [ $passFromFile == $pass ]; then
                user=$username
                mainMenu
            else    
                echo "Password is incorrect !!!"
            fi
        else
            echo "Username or Password is incorrect !!!"
        fi
    else
        echo "Username or Password is empty !!!"
    fi 
    echo " "
    read -p "Press (Y) to Login Again or (N) To Return Back to Home (Y/N): " proceed
        if [ $proceed == "Y" -o $proceed == "y" ]; then
            login
        elif [ $proceed == "N" -o $proceed == "n" ]; then
            home
        else
            login
        fi
    home
}

register() {
    echo ""
    echo "======================================"
    echo "         Registration System          "
    echo "======================================"
    read -p "Enter your Name: " name
    read -p "Enter your Username: " username
    read -p "Enter your Password: " pass
    read -p "Enter your Phone#: " phone
    echo " "
    if [ -n "$name" ] && [ -n "$username" ] && [ -n "$pass" ]; then
        line=$name" "$username" "$pass" "$phone
        echo -e "$line" >> users
        echo "User Registered Successfully!!!"
        read -p "Press Enter to continue...." proceed
    else
        echo "Some fields are empty !!!"
        echo " "
        read -p "Press (Y) to Register Again or (N) To Return Back to Home (Y/N): " proceed
        if [ $proceed == "Y" -o $proceed == "y" ]; then
            register
        elif [ $proceed == "N" -o $proceed == "n" ]; then
            home
        else
            register
        fi
    fi
    home
}

home(){
    clear
    figlet "Welcome  to  Store"
    check=1
    while [ $check -eq 1 ];
    do
        echo "1. Press 1 for Login";
        echo "2. Press 2 for Registeration";
        echo "3. Press 3 for Exit";
        echo " "
        read -p "Enter your choice: " choice
            case $choice in
                1)
                    clear
                    login
                    ;;
                2)
                    clear
                    register
                    ;;
                3)
                    exit
                    ;;
                *)
                    clear
                    echo "Enter the correct Input"
            esac
    done
}

mainMenu() {
    check=1
    while [ $check -eq 1 ];
    do
    #mainMenu here
    clear
    currTime=$(date +"%T")
    echo "==============================================="
    echo "Login as:                            $user"
    echo "Current Time:                         $currTime"
    echo "==============================================="
    echo " "
    echo "1. Press 1 for Grocery Items";
    echo "2. Press 2 for Add Item to Grocery List";
    echo "3. Press 3 for Remove Item from Grocery List";
    echo "4. Press 4 for Show Cart";
    echo "4. Press 5 for Order History";
    echo "5. Press 6 for Logout";
    echo " "
    read -p "Enter your choice: " choice
        case $choice in
            1)
                clear
                groceryItems ${itemList[*]} ${itemPrices[*]}
                echo ""
                read -p "Do you want to add Items to Cart:(Y/N) " dec

                if [ $dec == "Y" -o $dec == "y" ]; then        
                    addToCart
                else 
                    mainMenu
                fi
                ;;
            2)
                clear
                addItems
                ;;
            3)
                clear
                groceryItems ${itemList[*]} ${itemPrices[*]}
                echo ""
                removeItems
                ;;
            4)
                showCart
                ;;
            5)
                ordersHistory
                ;;
            6)
                user=""
                home
                ;;
            *)
                clear
                echo "Enter the correct Input"
        esac
    done
}

home
