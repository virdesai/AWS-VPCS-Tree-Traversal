#!/bin/bash
vpcsString=$(aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,Tags[?Key==`Name`].Value]' --output text)
vpcs=($vpcsString)
a=0
for i in ${vpcs[@]}; do
        if [ "$(($a%2))" -eq 0 ]; then
                subnetString="$(aws ec2 describe-subnets --filters 'Name=vpc-id, Values='$i'' --query 'Subnets[*].[Tags[?Key==`Name`].Value,SubnetId]' --output text)";
                subnet=($subnetString)
                b=0;
                for j in ${subnet[@]}; do
                        if [ "$(($b%2))" -eq 0  ]; then
                                c=0
                                naclString="$(aws ec2 describe-network-acls --filters 'Name=entry.cidr, Values=0.0.0.0/0,Name=entry.protocol,Values=-1,Name=entry.rule-action,Values=allow,Name=association.subnet-id,Values='$j'' --query 'NetworkAcls[*].[NetworkAclId,Tags[?Key==`Name`].Value]' --output text)";
                                sgString="$(aws ec2 describe-security-groups --filters 'Name=ip-permission.cidr,Values=0.0.0.0/0,Name=ip-permission.protocol,Values=-1,Name=vpc-id,Values='$i'' --query 'SecurityGroups[*].[Tags[?Key==`Name`].Value,GroupId]' --output text)";
                                nacl=($naclString)
                                sg=($sgString)
                                for k in ${sg[@]}; do
                                        if [ "$(($c%2))" -eq 1 ]; then
                                                instanceString="$(aws ec2 describe-instances --filters 'Name=instance.group-id,Values='$k'' --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value,InstanceId]' --output text)";
                                                index=0
                                                instance=($instanceString)
                                                for l in ${instance[@]}; do
                                                        if [ "$(($index%2))" -eq 0 ]; then
                                                                echo "vpcs id: ""$i";
                                                                echo "vpcs name: ""${vpcs[(($a+1))]}";
                                                                echo "subnet id: ""$j";
                                                                echo "subnet name: ""${subnet[(($b+1))]}"
                                                                echo "NACL id: ""${nacl[0]}";
                                                                echo "NACL name: ""${nacl[1]}";
                                                                echo "security group id: ""$k";
                                                                echo "security group name: ""${sg[(($c - 1))]}";
                                                                echo "ec2 instance id: ""$l";
                                                        else
                                                                echo "ec2 instance name: ""$l";
                                                                echo "";
                                                        fi
                                                        index=$[index+1]
                                                done
                                        fi
                                        c=$[c+1]
                                done
                        fi
                        b=$[b+1]
                done
        fi
        a=$[$a+1]
done
