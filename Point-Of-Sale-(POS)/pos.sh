#!/bin/bash

cartTotal=0
user=""

groceryItems(){    
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
        row=($i" "$itemName" "$itemPrice)
        tableFormat $row
    }
    
}

addItems(){
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
    read -p "Press any Key to Continue..." proceed
}

removeItems(){
    echo "======================================"
    echo "    Remove Items from Grocery List    "
    echo "======================================"
    read -p "Enter Item No to Remove: " itemNo
    echo " "
    if [ -n "$itemNo" ]; then
        sed -i "$(($itemNo+1))d" products     
        echo "Item Removed Successfully!!!"
    else
        echo "Item No is incorrect..."
    fi
    read -p "Press any Key to Continue..." proceed
}

addToCart() {
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
        echo " " 
        read -p "Press any Key to Continue..." proceed
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
        echo " " 
        read -p "Press any Key to Continue..." proceed
        mainMenu
    fi    
}

showCart() {
    clear
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
            row=($itemNo" "$itemName" "$itemQuantity" "$totalPriceOfItem)
            tableFormat $row
            
        }

        echo " "
        read -p "Proceed to Checkout (Y/N): " checkout
        echo " "
        if [ $checkout == "Y" -o $checkout == "y" ]; then
            cart=()
            echo "Your Total Bill: "$cartTotal
            read -p "Press P to Pay: " pay
            if [ $pay == "P" -o $pay == "p" ]; then
                echo -n "" > cart
                echo " "
                echo "Thanks for Shopping here, See you Again"
                read -p "Press Enter to continue...." proceed
            else     
                mainMenu
            fi    
        elif [ $checkout == "N" -o $checkout == "n" ]; then
            mainMenu
        fi
    fi
}

tableFormat() {
    local IFS=$' '
    printf "%-11s %-16s %-15s %-5s\n" $@
}

login() {
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
    read -p "Press Enter to continue...." proceed
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
        read -p "Press Enter to continue...." proceed
        register
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
    echo "==============================================="
    echo "Login as:                            $user"
    echo "==============================================="
    echo " "
    echo "1. Press 1 for Grocery Items";
    echo "2. Press 2 for Add Item to Grocery List";
    echo "3. Press 3 for Remove Item from Grocery List";
    echo "4. Press 4 for Show Cart";
    echo "5. Press 5 for Logout";
    echo " "
    read -p "Enter your choice: " choice
        case $choice in
            1)
                clear
                groceryItems ${itemList[*]} ${itemPrices[*]}
                echo ""
                read -p "Do you want to buy:(Y/N) " dec

                if [ $dec == "Y" -o $dec == "y" ]; then        
                    addToCart
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
